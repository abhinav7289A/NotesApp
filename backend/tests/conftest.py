"""Tests run without Docker: SQLite instead of Postgres, in-memory storage and queue."""

import uuid
from collections.abc import AsyncIterator
from pathlib import Path

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app import db_models  # noqa: F401
from app.config import Settings, get_settings
from app.db import Base, get_session
from app.main import app
from app.queue import get_queue
from app.storage import get_storage


class FakeStorage:
    def __init__(self) -> None:
        self.objects: dict[str, bytes] = {}
        self.puts = 0

    def presign_put(self, key: str, content_type: str, expires: int) -> str:
        return f"https://storage.test/{key}?op=put&expires={expires}"

    def presign_get(self, key: str, expires: int) -> str:
        return f"https://storage.test/{key}?op=get&expires={expires}"

    def get_bytes(self, key: str) -> bytes:
        if key not in self.objects:
            raise FileNotFoundError(key)
        return self.objects[key]

    def put_bytes(self, key: str, data: bytes, content_type: str) -> None:
        self.puts += 1
        self.objects[key] = data

    def exists(self, key: str) -> bool:
        return key in self.objects


class FakeQueue:
    def __init__(self) -> None:
        self.enqueued: list[tuple[uuid.UUID, int]] = []

    async def enqueue_ingest(self, job_id: uuid.UUID, attempt: int = 0) -> None:
        self.enqueued.append((job_id, attempt))


@pytest.fixture
def settings() -> Settings:
    return Settings(_env_file=None, eager_raster_pages=2, page_image_width_px=400)  # type: ignore[call-arg]


@pytest.fixture
def storage() -> FakeStorage:
    return FakeStorage()


@pytest.fixture
def queue() -> FakeQueue:
    return FakeQueue()


@pytest.fixture
async def sessionmaker(tmp_path: Path) -> AsyncIterator[async_sessionmaker[AsyncSession]]:
    engine = create_async_engine(f"sqlite+aiosqlite:///{tmp_path / 'test.db'}")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield async_sessionmaker(engine, expire_on_commit=False)
    await engine.dispose()


@pytest.fixture
async def client(
    sessionmaker: async_sessionmaker[AsyncSession], storage: FakeStorage, queue: FakeQueue, settings: Settings
) -> AsyncIterator[AsyncClient]:
    async def session_override() -> AsyncIterator[AsyncSession]:
        async with sessionmaker() as s:
            yield s

    app.dependency_overrides[get_session] = session_override
    app.dependency_overrides[get_storage] = lambda: storage
    app.dependency_overrides[get_queue] = lambda: queue
    app.dependency_overrides[get_settings] = lambda: settings
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()
