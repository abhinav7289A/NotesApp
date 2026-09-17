"""The migration must produce exactly the tables in db_models, and db-reset must work from scratch (acceptance check 9)."""

import asyncio
from pathlib import Path

from alembic.autogenerate import compare_metadata
from alembic.migration import MigrationContext
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.db import Base
from app.db_models import Chapter, Document
from scripts import db_reset


def test_db_reset_migrates_and_seeds(tmp_path: Path) -> None:
    url = f"sqlite+aiosqlite:///{tmp_path / 'reset.db'}"
    db_reset.main(url)
    db_reset.main(url)  # running twice must also work

    async def check() -> None:
        engine = create_async_engine(url)
        async with engine.connect() as conn:
            diff = await conn.run_sync(lambda c: compare_metadata(MigrationContext.configure(c), Base.metadata))
        assert diff == [], f"migration and models disagree: {diff}"
        async with async_sessionmaker(engine)() as s:
            assert await s.scalar(select(func.count()).select_from(Chapter)) == 3
            assert await s.scalar(select(func.count()).select_from(Document).where(Document.status == "ready")) == 3
        await engine.dispose()

    asyncio.run(check())
