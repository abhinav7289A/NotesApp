"""Drop everything, run migrations, seed the contract fixtures as ready documents for the dev user.

    python backend/scripts/db_reset.py            (uses DATABASE_URL from .env)

Seeded chapters have no source PDF, so their page images will not render — use a real upload for that.
"""

import asyncio
import json
import sys
import uuid
from pathlib import Path

BACKEND = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND))

from alembic import command  # noqa: E402
from alembic.config import Config  # noqa: E402
from sqlalchemy import text  # noqa: E402
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine  # noqa: E402

from app.config import REPO_ROOT, get_settings  # noqa: E402
from app.db import Base  # noqa: E402
from app.db_models import Chapter, Document, Page  # noqa: E402

FIXTURES = REPO_ROOT / "contracts" / "fixtures"


async def _drop(url: str) -> None:
    engine = create_async_engine(url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.execute(text("DROP TABLE IF EXISTS alembic_version"))
    await engine.dispose()


def _migrate(url: str) -> None:
    cfg = Config(str(BACKEND / "alembic.ini"))
    cfg.set_main_option("script_location", str(BACKEND / "migrations"))
    cfg.attributes["database_url"] = url
    cfg.attributes["configure_logger"] = False
    command.upgrade(cfg, "head")


async def _seed(url: str) -> int:
    settings = get_settings()
    engine = create_async_engine(url)
    count = 0
    async with async_sessionmaker(engine)() as s:
        for path in sorted(FIXTURES.glob("chapter_*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            chapter_id = uuid.UUID(data["chapter_id"])
            chapter = Chapter(
                id=chapter_id, content_hash=data["content_hash"], schema_version=data["schema_version"], title=data["title"],
                language=data["language"], payload=data, ocr_engine=data.get("ocr_engine"), source_key=f"fixtures/{path.stem}.pdf",
            )
            s.add(chapter)
            s.add_all(
                Page(chapter_id=chapter_id, page_id=p["page_id"], index=p["index"], width_pt=p["width_pt"],
                     height_pt=p["height_pt"], image_key=None)
                for p in data["pages"]
            )
            s.add(Document(
                user_id=settings.dev_user_id, filename=data.get("source_filename") or f"{path.stem}.pdf", size_bytes=1,
                source_key=chapter.source_key, content_hash=data["content_hash"], chapter_id=chapter_id,
                status="ready", progress=100, page_count=data["page_count"],
            ))
            count += 1
        await s.commit()
    await engine.dispose()
    return count


def main(url: str | None = None) -> None:
    url = url or get_settings().async_database_url
    asyncio.run(_drop(url))
    _migrate(url)
    seeded = asyncio.run(_seed(url))
    print(f"database reset: migrated to head, seeded {seeded} fixture chapter(s)")


if __name__ == "__main__":
    main()
