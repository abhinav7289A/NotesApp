"""P1 endpoints."""

import asyncio
from typing import Annotated, Any
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException
from fastapi import Path as PathParam
from fastapi import status as http
from fastapi.responses import JSONResponse, RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.db import get_session
from app.db_models import Chapter, Document, Job, Page
from app.ingest.jobs import page_image_key
from app.ingest.pdf import render_pdf_page_webp
from app.models import (
    PAGE_ID_PATTERN,
    ApiError,
    CanonicalChapter,
    CreateDocumentRequest,
    CreateDocumentResponse,
    DocumentError,
    DocumentStatus,
    DocumentSummary,
    ErrorCode,
    IngestResponse,
)
from app.queue import Queue, get_queue
from app.storage import Storage, get_storage

router = APIRouter(prefix="/v1")

SessionDep = Annotated[AsyncSession, Depends(get_session)]
StorageDep = Annotated[Storage, Depends(get_storage)]
QueueDep = Annotated[Queue, Depends(get_queue)]
SettingsDep = Annotated[Settings, Depends(get_settings)]

ERRORS: dict[int | str, dict[str, Any]] = {404: {"model": ApiError}, 409: {"model": ApiError}}


def _error(status_code: int, code: str, message: str) -> HTTPException:
    return HTTPException(status_code=status_code, detail={"code": code, "message": message})


def _summary(doc: Document) -> DocumentSummary:
    return DocumentSummary(
        document_id=doc.id,
        filename=doc.filename,
        status=DocumentStatus(doc.status),
        progress=doc.progress,
        page_count=doc.page_count,
        chapter_id=doc.chapter_id,
        error=DocumentError(code=ErrorCode(doc.error_code), message=doc.error_message or "") if doc.error_code else None,
        created_at=doc.created_at,
    )


async def _get_document(session: AsyncSession, document_id: UUID, settings: Settings) -> Document:
    doc = await session.get(Document, document_id)
    if doc is None or doc.user_id != settings.dev_user_id:
        raise _error(http.HTTP_404_NOT_FOUND, "NOT_FOUND", "Document not found.")
    return doc


@router.post("/documents", response_model=CreateDocumentResponse, status_code=http.HTTP_201_CREATED, responses={413: {"model": ApiError}})
async def create_document(body: CreateDocumentRequest, session: SessionDep, storage: StorageDep, settings: SettingsDep) -> CreateDocumentResponse:
    """Register an upload. The client PUTs the PDF bytes to `upload_url` (Content-Type: application/pdf), then calls ingest."""
    if body.size_bytes > settings.max_upload_bytes:
        raise _error(http.HTTP_413_REQUEST_ENTITY_TOO_LARGE, ErrorCode.FILE_TOO_LARGE.value, "PDFs must be 40 MB or smaller.")
    document_id = uuid4()
    key = f"uploads/{settings.dev_user_id}/{document_id}.pdf"
    session.add(Document(id=document_id, user_id=settings.dev_user_id, filename=body.filename, size_bytes=body.size_bytes,
                         source_key=key, status="uploaded", progress=0))
    await session.commit()
    return CreateDocumentResponse(
        document_id=document_id, upload_url=storage.presign_put(key, "application/pdf", settings.signed_url_ttl_seconds)
    )


@router.get("/documents", response_model=list[DocumentSummary])
async def list_documents(session: SessionDep, settings: SettingsDep) -> list[DocumentSummary]:
    docs = await session.scalars(select(Document).where(Document.user_id == settings.dev_user_id).order_by(Document.created_at.desc()))
    return [_summary(d) for d in docs]


@router.post("/documents/{document_id}/ingest", response_model=IngestResponse, status_code=http.HTTP_202_ACCEPTED, responses=ERRORS)
async def ingest_document(
    document_id: UUID, session: SessionDep, storage: StorageDep, queue: QueueDep, settings: SettingsDep
) -> IngestResponse:
    """Idempotent: calling again while a job is queued/running, or after success, returns the existing job."""
    doc = await _get_document(session, document_id, settings)
    latest = await session.scalar(select(Job).where(Job.document_id == doc.id).order_by(Job.created_at.desc()).limit(1))
    if latest is not None and (latest.state in ("queued", "running") or doc.status == "ready"):
        return IngestResponse(job_id=latest.id)
    if doc.status == "ready":
        job = Job(document_id=doc.id, type="ingest", state="done")
        session.add(job)
        await session.commit()
        return IngestResponse(job_id=job.id)
    if not await asyncio.to_thread(storage.exists, doc.source_key):
        raise _error(http.HTTP_409_CONFLICT, "UPLOAD_MISSING", "Upload the file to upload_url before starting ingest.")

    job = Job(document_id=doc.id, type="ingest", state="queued")
    doc.status, doc.progress, doc.error_code, doc.error_message = "uploaded", 0, None, None
    session.add(job)
    await session.commit()
    await queue.enqueue_ingest(job.id)
    return IngestResponse(job_id=job.id)


@router.get("/documents/{document_id}", response_model=DocumentSummary, responses=ERRORS)
async def get_document(document_id: UUID, session: SessionDep, settings: SettingsDep) -> DocumentSummary:
    """Poll this for status and progress (0–100) while ingest runs."""
    return _summary(await _get_document(session, document_id, settings))


@router.get("/documents/{document_id}/chapter", response_model=CanonicalChapter, responses=ERRORS)
async def get_chapter(document_id: UUID, session: SessionDep, settings: SettingsDep) -> JSONResponse:
    doc = await _get_document(session, document_id, settings)
    chapter = await session.get(Chapter, doc.chapter_id) if doc.chapter_id else None
    if chapter is None:
        raise _error(http.HTTP_409_CONFLICT, "NOT_READY", f"Document is {doc.status}.")
    # Lazily rendered pages get their image_key after ingest; overlay the current keys.
    keys = dict((await session.execute(select(Page.page_id, Page.image_key).where(Page.chapter_id == chapter.id))).tuples().all())
    payload = {**chapter.payload, "pages": [{**p, "image_key": keys.get(p["page_id"], p["image_key"])} for p in chapter.payload["pages"]]}
    return JSONResponse(payload)


@router.get(
    "/chapters/{chapter_id}/pages/{page_id}/image",
    status_code=http.HTTP_302_FOUND,
    response_class=RedirectResponse,
    responses={302: {"description": "Redirect to a signed image URL valid for 15 minutes. Never cache it."}, 404: {"model": ApiError}},
)
async def get_page_image(
    chapter_id: UUID,
    page_id: Annotated[str, PathParam(pattern=PAGE_ID_PATTERN)],
    session: SessionDep,
    storage: StorageDep,
    settings: SettingsDep,
) -> RedirectResponse:
    page = await session.get(Page, (chapter_id, page_id))
    chapter = await session.get(Chapter, chapter_id)
    if page is None or chapter is None:
        raise _error(http.HTTP_404_NOT_FOUND, "NOT_FOUND", "Page not found.")
    if page.image_key is None:
        key = page_image_key(chapter.content_hash, page_id)
        if not await asyncio.to_thread(storage.exists, key):
            data = await asyncio.to_thread(storage.get_bytes, chapter.source_key)
            webp = await asyncio.to_thread(render_pdf_page_webp, data, page.index, settings.page_image_width_px)
            await asyncio.to_thread(storage.put_bytes, key, webp, "image/webp")
        page.image_key = key
        await session.commit()
    url = storage.presign_get(page.image_key, settings.signed_url_ttl_seconds)
    return RedirectResponse(url, status_code=http.HTTP_302_FOUND, headers={"Cache-Control": "no-store"})
