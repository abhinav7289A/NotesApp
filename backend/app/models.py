"""API models. Source of truth for contracts/openapi.json — regenerate after any change."""

from datetime import datetime
from enum import Enum
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

PAGE_ID_PATTERN = r"^p[0-9]{5}$"
BLOCK_ID_PATTERN = r"^p[0-9]{5}_b[0-9]{3}$"


class BlockType(str, Enum):
    heading = "heading"
    paragraph = "paragraph"
    list_item = "list_item"
    figure = "figure"
    caption = "caption"
    table = "table"
    formula = "formula"
    header = "header"
    footer = "footer"
    page_number = "page_number"


class Page(BaseModel):
    model_config = ConfigDict(extra="forbid")

    page_id: str = Field(pattern=PAGE_ID_PATTERN, examples=["p00001"])
    index: int = Field(ge=0, examples=[0])
    width_pt: float = Field(examples=[595.0])
    height_pt: float = Field(examples=[842.0])
    rotation: Literal[0, 90, 180, 270] = Field(default=0, examples=[0])
    image_key: str | None = Field(default=None, examples=["pages/3f9a.../p00001.webp"])
    has_text_layer: bool | None = Field(default=None, examples=[True])


class Block(BaseModel):
    model_config = ConfigDict(extra="forbid")

    block_id: str = Field(pattern=BLOCK_ID_PATTERN, examples=["p00001_b001"])
    page_id: str = Field(pattern=PAGE_ID_PATTERN, examples=["p00001"])
    type: BlockType = Field(examples=["paragraph"])
    text: str | None = Field(default=None, examples=["Photosynthesis is the process by which green plants make food."])
    bbox: list[float] = Field(min_length=4, max_length=4, examples=[[0.1, 0.2, 0.9, 0.3]])
    order: int = Field(examples=[1])
    level: int | None = Field(default=None, examples=[None])
    confidence: float | None = Field(default=None, ge=0, le=1, examples=[None])
    image_key: str | None = Field(default=None, examples=[None])


class CanonicalChapter(BaseModel):
    model_config = ConfigDict(extra="forbid")

    schema_version: Literal[1] = Field(examples=[1])
    chapter_id: UUID = Field(examples=["6f1c2a4e-2b7d-4c1e-9a3f-1d2e3f4a5b6c"])
    content_hash: str = Field(pattern=r"^[a-f0-9]{64}$", examples=["a" * 64])
    title: str = Field(examples=["Life Processes"])
    source_filename: str | None = Field(default=None, examples=["jesc106.pdf"])
    language: str = Field(examples=["en"])
    page_count: int = Field(ge=1, examples=[60])
    ocr_engine: str | None = Field(default=None, examples=["pdf-text-layer"])
    created_at: datetime | None = Field(default=None, examples=["2026-09-14T10:00:00Z"])
    pages: list[Page]
    blocks: list[Block]


class DocumentStatus(str, Enum):
    uploaded = "uploaded"
    processing = "processing"
    ready = "ready"
    failed = "failed"


class ErrorCode(str, Enum):
    SCAN_TOO_POOR = "SCAN_TOO_POOR"
    ENCRYPTED_PDF = "ENCRYPTED_PDF"
    TOO_MANY_PAGES = "TOO_MANY_PAGES"
    CORRUPT_FILE = "CORRUPT_FILE"


class DocumentError(BaseModel):
    code: ErrorCode = Field(examples=["ENCRYPTED_PDF"])
    message: str = Field(examples=["This PDF is password protected."])


class CreateDocumentRequest(BaseModel):
    filename: str = Field(examples=["jesc106.pdf"])
    size_bytes: int = Field(gt=0, examples=[4_200_000])


class CreateDocumentResponse(BaseModel):
    document_id: UUID = Field(examples=["0b8e7c1a-5d2f-4e3b-8a9c-7d6e5f4a3b2c"])
    upload_url: str = Field(examples=["https://r2.example.com/uploads/0b8e...?X-Amz-Signature=..."])


class IngestResponse(BaseModel):
    job_id: UUID = Field(examples=["9a8b7c6d-5e4f-4a3b-9c2d-1e0f9a8b7c6d"])


class DocumentSummary(BaseModel):
    document_id: UUID = Field(examples=["0b8e7c1a-5d2f-4e3b-8a9c-7d6e5f4a3b2c"])
    filename: str = Field(examples=["jesc106.pdf"])
    status: DocumentStatus = Field(examples=["processing"])
    progress: int = Field(ge=0, le=100, examples=[42])
    page_count: int | None = Field(default=None, examples=[60])
    chapter_id: UUID | None = Field(default=None, examples=[None])
    error: DocumentError | None = Field(default=None, examples=[None])
    created_at: datetime = Field(examples=["2026-09-14T10:00:00Z"])
