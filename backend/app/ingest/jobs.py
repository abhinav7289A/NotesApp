"""Ingest job orchestration: storage + database + pipeline. Runs inside the ARQ worker."""

import asyncio
import hashlib
import logging
import uuid
from datetime import UTC, datetime

from sqlalchemy import func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.config import Settings
from app.db_models import Chapter, Document, Job, Page
from app.ingest.build import build_chapter, validate_chapter
from app.ingest.pdf import IngestError, extract_raw_page, open_pdf, render_page_webp
from app.models import ErrorCode
from app.queue import Queue
from app.storage import Storage

log = logging.getLogger(__name__)

MAX_ATTEMPTS = 3


def page_image_key(content_hash: str, page_id: str) -> str:
    return f"pages/{content_hash}/{page_id}.webp"


async def run_ingest(job_id: uuid.UUID, sessionmaker: async_sessionmaker[AsyncSession], storage: Storage, settings: Settings) -> None:
    async with sessionmaker() as s:
        job = await s.get(Job, job_id)
        if job is None:
            log.warning("ingest job %s not found", job_id)
            return
        if job.state in ("done", "failed"):
            return
        doc = await s.get(Document, job.document_id)
        if doc is None:
            return
        document_id = doc.id
        if doc.status == "ready":
            job.state = "done"
            await s.commit()
            return

        job.state = "running"
        job.attempts += 1
        doc.status, doc.progress, doc.error_code, doc.error_message = "processing", 0, None, None
        await s.commit()

        try:
            await _ingest(s, doc, storage, settings)
            await s.execute(update(Job).where(Job.id == job_id).values(state="done", last_error=None))
            await s.commit()
            return
        except IngestError as e:
            code, message = e.code, e.message
        except Exception:
            log.exception("ingest job %s crashed", job_id)
            code, message = ErrorCode.INTERNAL_ERROR, "Something went wrong while processing this PDF."
    await _mark_failed(sessionmaker, job_id, document_id, code, message)


async def _mark_failed(
    sessionmaker: async_sessionmaker[AsyncSession], job_id: uuid.UUID, document_id: uuid.UUID, code: ErrorCode, message: str
) -> None:
    async with sessionmaker() as s:
        await s.execute(update(Job).where(Job.id == job_id).values(state="failed", last_error=f"{code.value}: {message}"))
        await s.execute(
            update(Document).where(Document.id == document_id).values(status="failed", error_code=code.value, error_message=message)
        )
        await s.commit()


async def _link_existing_chapter(s: AsyncSession, doc: Document, content_hash: str) -> bool:
    """Dedup: identical bytes already processed → point this document at that chapter. No reprocessing."""
    chapter_id = await s.scalar(select(Chapter.id).where(Chapter.content_hash == content_hash))
    if chapter_id is None:
        return False
    doc.chapter_id = chapter_id
    doc.page_count = await s.scalar(select(func.count()).select_from(Page).where(Page.chapter_id == chapter_id))
    doc.status, doc.progress = "ready", 100
    await s.commit()
    return True


async def _ingest(s: AsyncSession, doc: Document, storage: Storage, settings: Settings) -> None:
    try:
        data = await asyncio.to_thread(storage.get_bytes, doc.source_key)
    except FileNotFoundError as e:
        raise IngestError(ErrorCode.CORRUPT_FILE, "The upload was not found. Upload the file again.") from e
    if len(data) > settings.max_upload_bytes:
        raise IngestError(ErrorCode.FILE_TOO_LARGE, "PDFs must be 40 MB or smaller.")

    content_hash = hashlib.sha256(data).hexdigest()
    doc.content_hash, doc.size_bytes = content_hash, len(data)
    await s.commit()
    if await _link_existing_chapter(s, doc, content_hash):
        return

    pdf = open_pdf(data, settings.max_pages)
    try:
        n = pdf.page_count
        doc.page_count = n
        raw_pages = []
        for i in range(n):
            raw_pages.append(await asyncio.to_thread(extract_raw_page, pdf[i], i))
            doc.progress = round((i + 1) * 80 / n)
            await s.commit()

        if sum(1 for p in raw_pages if not p.has_text_layer) * 2 > n:
            raise IngestError(ErrorCode.SCAN_TOO_POOR, "This looks like a scanned PDF. Scanned pages are not supported yet.")

        payload = build_chapter(
            raw_pages, chapter_id=uuid.uuid4(), content_hash=content_hash, filename=doc.filename, created_at=datetime.now(UTC)
        )

        # Render only the first pages now; the rest render lazily on request and are cached forever.
        eager = min(settings.eager_raster_pages, n)
        for i in range(eager):
            webp = await asyncio.to_thread(render_page_webp, pdf[i], settings.page_image_width_px)
            key = page_image_key(content_hash, payload["pages"][i]["page_id"])
            await asyncio.to_thread(storage.put_bytes, key, webp, "image/webp")
            payload["pages"][i]["image_key"] = key
            doc.progress = 80 + round((i + 1) * 19 / eager)
            await s.commit()
    finally:
        pdf.close()

    validate_chapter(payload)

    chapter = Chapter(
        id=uuid.UUID(payload["chapter_id"]),
        content_hash=content_hash,
        schema_version=payload["schema_version"],
        title=payload["title"],
        language=payload["language"],
        payload=payload,
        ocr_engine=payload["ocr_engine"],
        source_key=doc.source_key,
    )
    s.add(chapter)
    s.add_all(
        Page(chapter_id=chapter.id, page_id=p["page_id"], index=p["index"], width_pt=p["width_pt"], height_pt=p["height_pt"],
             image_key=p["image_key"])
        for p in payload["pages"]
    )
    try:
        await s.flush()
    except IntegrityError:
        # Another worker finished the same bytes first. Use its chapter.
        await s.rollback()
        await s.refresh(doc)
        if await _link_existing_chapter(s, doc, content_hash):
            return
        raise

    doc.chapter_id, doc.status, doc.progress = chapter.id, "ready", 100
    await s.commit()


async def recover_stuck_jobs(sessionmaker: async_sessionmaker[AsyncSession], queue: Queue) -> int:
    """Worker startup: a job left 'running' means the worker died mid-job. Requeue it, or fail it after MAX_ATTEMPTS.

    Assumes a single worker process (true for P1). With several workers this would steal live jobs.
    """
    requeue: list[tuple[uuid.UUID, int]] = []
    async with sessionmaker() as s:
        jobs = (await s.scalars(select(Job).where(Job.state == "running"))).all()
        for job in jobs:
            if job.attempts >= MAX_ATTEMPTS:
                job.state, job.last_error = "failed", "worker stopped mid-job too many times"
                await s.execute(
                    update(Document)
                    .where(Document.id == job.document_id)
                    .values(status="failed", error_code=ErrorCode.INTERNAL_ERROR.value,
                            error_message="Processing kept stopping. Try uploading again.")
                )
            else:
                job.state = "queued"
                await s.execute(update(Document).where(Document.id == job.document_id).values(status="uploaded", progress=0))
                requeue.append((job.id, job.attempts))
        await s.commit()
    for job_id, attempt in requeue:
        await queue.enqueue_ingest(job_id, attempt)
    return len(jobs)
