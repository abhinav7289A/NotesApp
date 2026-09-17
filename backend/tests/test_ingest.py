"""End-to-end ingest through the API with real PDFs, SQLite, fake storage and queue."""

import uuid

from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.config import Settings
from app.db_models import Document, Job
from app.ingest.build import validate_chapter
from app.ingest.jobs import MAX_ATTEMPTS, recover_stuck_jobs, run_ingest
from tests import pdfs
from tests.conftest import FakeQueue, FakeStorage


async def upload_and_ingest(
    client: AsyncClient,
    data: bytes,
    storage: FakeStorage,
    queue: FakeQueue,
    sessionmaker: async_sessionmaker[AsyncSession],
    settings: Settings,
    filename: str = "chapter.pdf",
) -> dict:
    r = await client.post("/v1/documents", json={"filename": filename, "size_bytes": len(data)})
    assert r.status_code == 201, r.text
    body = r.json()
    assert "op=put" in body["upload_url"]
    doc_id = body["document_id"]
    async with sessionmaker() as s:
        doc = await s.get(Document, uuid.UUID(doc_id))
        assert doc is not None
        storage.objects[doc.source_key] = data  # what the client's presigned PUT does

    r = await client.post(f"/v1/documents/{doc_id}/ingest")
    assert r.status_code == 202, r.text
    job_id = uuid.UUID(r.json()["job_id"])
    assert queue.enqueued[-1][0] == job_id

    await run_ingest(job_id, sessionmaker, storage, settings)  # what the worker does
    r = await client.get(f"/v1/documents/{doc_id}")
    assert r.status_code == 200
    return r.json()


async def test_one_column_pdf_reaches_ready_and_validates(client, storage, queue, sessionmaker, settings) -> None:
    status = await upload_and_ingest(client, pdfs.one_column(3), storage, queue, sessionmaker, settings)
    assert status["status"] == "ready", status
    assert status["progress"] == 100 and status["page_count"] == 3

    r = await client.get(f"/v1/documents/{status['document_id']}/chapter")
    assert r.status_code == 200
    chapter = r.json()
    validate_chapter(chapter)
    types = {b["type"] for b in chapter["blocks"]}
    assert {"heading", "paragraph", "list_item", "header", "page_number"} <= types, types
    assert chapter["title"] == "Chapter part 1"
    assert [p["image_key"] is not None for p in chapter["pages"]] == [True, True, False]  # eager_raster_pages=2
    assert all(0 <= v <= 1 for b in chapter["blocks"] for v in b["bbox"])


async def test_two_column_reading_order(client, storage, queue, sessionmaker, settings) -> None:
    status = await upload_and_ingest(client, pdfs.two_column(2), storage, queue, sessionmaker, settings)
    chapter = (await client.get(f"/v1/documents/{status['document_id']}/chapter")).json()
    tags = [b["text"].split()[0] for b in chapter["blocks"] if b["type"] == "paragraph"]
    assert tags == ["LEFT0A", "LEFT0B", "RIGHT0A", "RIGHT0B", "LEFT1A", "LEFT1B", "RIGHT1A", "RIGHT1B"]


async def test_same_bytes_dedup_without_reprocessing(client, storage, queue, sessionmaker, settings) -> None:
    data = pdfs.one_column(2)
    first = await upload_and_ingest(client, data, storage, queue, sessionmaker, settings)
    puts_after_first = storage.puts
    second = await upload_and_ingest(client, data, storage, queue, sessionmaker, settings, filename="copy.pdf")
    assert second["status"] == "ready"
    assert second["chapter_id"] == first["chapter_id"]
    assert second["document_id"] != first["document_id"]
    assert storage.puts == puts_after_first  # no pages re-rendered

    listing = (await client.get("/v1/documents")).json()
    assert {d["filename"] for d in listing} == {"chapter.pdf", "copy.pdf"}


async def test_error_codes(client, storage, queue, sessionmaker, settings) -> None:
    cases = [
        (pdfs.encrypted(), "ENCRYPTED_PDF"),
        (b"%PDF-1.4 this is not really a pdf", "CORRUPT_FILE"),
        (pdfs.no_text(2), "SCAN_TOO_POOR"),
    ]
    for data, code in cases:
        status = await upload_and_ingest(client, data, storage, queue, sessionmaker, settings)
        assert status["status"] == "failed", (code, status)
        assert status["error"]["code"] == code
        assert status["error"]["message"]

    settings.max_pages = 2
    status = await upload_and_ingest(client, pdfs.one_column(3), storage, queue, sessionmaker, settings)
    assert status["error"]["code"] == "TOO_MANY_PAGES"


async def test_upload_validation(client) -> None:
    r = await client.post("/v1/documents", json={"filename": "big.pdf", "size_bytes": 41 * 1024 * 1024})
    assert r.status_code == 413 and r.json()["detail"]["code"] == "FILE_TOO_LARGE"
    r = await client.post("/v1/documents", json={"filename": "notes.docx", "size_bytes": 10})
    assert r.status_code == 422
    r = await client.post("/v1/documents", json={"filename": "a.pdf", "size_bytes": 10})
    r = await client.post(f"/v1/documents/{r.json()['document_id']}/ingest")
    assert r.status_code == 409 and r.json()["detail"]["code"] == "UPLOAD_MISSING"
    assert (await client.get(f"/v1/documents/{uuid.uuid4()}")).status_code == 404


async def test_ingest_is_idempotent(client, storage, queue, sessionmaker, settings) -> None:
    status = await upload_and_ingest(client, pdfs.one_column(1), storage, queue, sessionmaker, settings)
    r1 = await client.post(f"/v1/documents/{status['document_id']}/ingest")
    r2 = await client.post(f"/v1/documents/{status['document_id']}/ingest")
    assert r1.json()["job_id"] == r2.json()["job_id"]
    assert len(queue.enqueued) == 1


async def test_page_image_eager_and_lazy(client, storage, queue, sessionmaker, settings) -> None:
    status = await upload_and_ingest(client, pdfs.one_column(3), storage, queue, sessionmaker, settings)
    chapter_id = status["chapter_id"]

    eager = await client.get(f"/v1/chapters/{chapter_id}/pages/p00001/image")
    assert eager.status_code == 302
    assert eager.headers["cache-control"] == "no-store"
    assert "expires=900" in eager.headers["location"]

    puts = storage.puts
    lazy = await client.get(f"/v1/chapters/{chapter_id}/pages/p00003/image")
    assert lazy.status_code == 302 and storage.puts == puts + 1
    assert storage.objects[lazy.headers["location"].split("https://storage.test/")[1].split("?")[0]][:4] == b"RIFF"  # WebP
    await client.get(f"/v1/chapters/{chapter_id}/pages/p00003/image")
    assert storage.puts == puts + 1  # rendered once, cached forever

    chapter = (await client.get(f"/v1/documents/{status['document_id']}/chapter")).json()
    assert chapter["pages"][2]["image_key"] is not None
    assert (await client.get(f"/v1/chapters/{chapter_id}/pages/p00009/image")).status_code == 404


async def test_worker_crash_recovery(client, storage, queue, sessionmaker, settings) -> None:
    """Acceptance check 8: a job left 'running' by a dead worker is requeued, then failed cleanly after MAX_ATTEMPTS."""
    data = pdfs.one_column(1)
    r = await client.post("/v1/documents", json={"filename": "c.pdf", "size_bytes": len(data)})
    doc_id = uuid.UUID(r.json()["document_id"])
    async with sessionmaker() as s:
        doc = await s.get(Document, doc_id)
        assert doc is not None
        storage.objects[doc.source_key] = data
        doc.status = "processing"
        job = Job(document_id=doc_id, type="ingest", state="running", attempts=1)
        s.add(job)
        await s.commit()
        job_id = job.id

    assert await recover_stuck_jobs(sessionmaker, queue) == 1
    assert queue.enqueued[-1] == (job_id, 1)
    await run_ingest(job_id, sessionmaker, storage, settings)
    assert (await client.get(f"/v1/documents/{doc_id}")).json()["status"] == "ready"

    async with sessionmaker() as s:
        job = await s.scalar(select(Job).where(Job.id == job_id))
        assert job is not None and job.state == "done"
        job.state, job.attempts = "running", MAX_ATTEMPTS
        await s.commit()
    await recover_stuck_jobs(sessionmaker, queue)
    async with sessionmaker() as s:
        job = await s.get(Job, job_id)
        assert job is not None and job.state == "failed"
