"""P1 endpoints. Stubs until the ingest pipeline lands — shapes are the contract."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from app.models import (
    CanonicalChapter,
    CreateDocumentRequest,
    CreateDocumentResponse,
    DocumentSummary,
    IngestResponse,
)

router = APIRouter(prefix="/v1")


def _not_implemented() -> HTTPException:
    return HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail="not implemented yet")


@router.post("/documents", response_model=CreateDocumentResponse, status_code=status.HTTP_201_CREATED)
async def create_document(body: CreateDocumentRequest) -> CreateDocumentResponse:
    raise _not_implemented()


@router.get("/documents", response_model=list[DocumentSummary])
async def list_documents() -> list[DocumentSummary]:
    raise _not_implemented()


@router.post("/documents/{document_id}/ingest", response_model=IngestResponse, status_code=status.HTTP_202_ACCEPTED)
async def ingest_document(document_id: UUID) -> IngestResponse:
    raise _not_implemented()


@router.get("/documents/{document_id}", response_model=DocumentSummary)
async def get_document(document_id: UUID) -> DocumentSummary:
    raise _not_implemented()


@router.get("/documents/{document_id}/chapter", response_model=CanonicalChapter)
async def get_chapter(document_id: UUID) -> CanonicalChapter:
    raise _not_implemented()


@router.get("/pages/{page_id}/image", status_code=status.HTTP_302_FOUND, responses={302: {"description": "Redirect to a signed R2 URL, 15 min expiry"}})
async def get_page_image(page_id: str) -> None:
    raise _not_implemented()
