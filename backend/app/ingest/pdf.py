"""Everything that touches PyMuPDF. Functions are sync and CPU-bound — call them via asyncio.to_thread."""

import io
import re

import pymupdf
from PIL import Image

from app.ingest.build import RawBlock, RawPage
from app.ingest.layout import Bbox, is_garbage_text, normalize_bbox
from app.models import ErrorCode


# C0 controls (NUL etc.) show up where fonts map math symbols oddly; Postgres jsonb rejects \u0000.
_CONTROL_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")


def clean_text(text: str) -> str:
    return _CONTROL_RE.sub(" ", text)


class IngestError(Exception):
    """A failure the client should render a specific screen for."""

    def __init__(self, code: ErrorCode, message: str) -> None:
        super().__init__(f"{code.value}: {message}")
        self.code = code
        self.message = message


def open_pdf(data: bytes, max_pages: int) -> pymupdf.Document:
    try:
        doc = pymupdf.open(stream=data, filetype="pdf")
    except Exception as e:
        raise IngestError(ErrorCode.CORRUPT_FILE, "This file is not a readable PDF.") from e
    if doc.needs_pass:
        doc.close()
        raise IngestError(ErrorCode.ENCRYPTED_PDF, "This PDF is password protected. Remove the password and upload again.")
    if doc.page_count == 0:
        doc.close()
        raise IngestError(ErrorCode.CORRUPT_FILE, "This PDF has no pages.")
    if doc.page_count > max_pages:
        count = doc.page_count
        doc.close()
        raise IngestError(ErrorCode.TOO_MANY_PAGES, f"This PDF has {count} pages. The limit is {max_pages}.")
    return doc


def extract_raw_page(page: pymupdf.Page, index: int) -> RawPage:
    # Canonical bboxes are relative to the UNROTATED page. PyMuPDF 1.25 text extraction already returns unrotated
    # coordinates (verified by tests/test_pdf.py), so normalize by the unrotated cropbox size — do not derotate.
    width, height = page.cropbox.width, page.cropbox.height

    def norm(rect: tuple[float, float, float, float]) -> Bbox | None:
        r = pymupdf.Rect(rect)
        r.normalize()
        bbox = normalize_bbox((r.x0, r.y0, r.x1, r.y1), width, height)
        return bbox if bbox[2] > bbox[0] and bbox[3] > bbox[1] else None

    flags = pymupdf.TEXTFLAGS_DICT & ~pymupdf.TEXT_PRESERVE_IMAGES
    blocks: list[RawBlock] = []
    for blk in page.get_text("dict", flags=flags)["blocks"]:
        if blk.get("type") != 0:
            continue
        lines: list[str] = []
        size_sum = 0.0
        chars = 0
        for line in blk["lines"]:
            text = " ".join(clean_text("".join(span["text"] for span in line["spans"])).split())
            if text:
                lines.append(text)
            for span in line["spans"]:
                n = len(span["text"].strip())
                size_sum += span["size"] * n
                chars += n
        bbox = norm(blk["bbox"])
        if lines and bbox:
            blocks.append(RawBlock(bbox, " ".join(lines), font_size=round(size_sum / max(chars, 1), 2)))

    has_text_layer = bool(blocks) and not is_garbage_text(" ".join(b.text or "" for b in blocks))
    if not has_text_layer:
        blocks = []  # OCR (P1 week 2) fills these in

    for info in page.get_image_info():
        bbox = norm(info["bbox"])
        if bbox is None:
            continue
        area = (bbox[2] - bbox[0]) * (bbox[3] - bbox[1])
        if 0.02 <= area <= 0.85:  # skip icons and full-page scan backgrounds
            blocks.append(RawBlock(bbox, None, is_figure=True))

    return RawPage(index, width, height, page.rotation, has_text_layer, blocks)


def render_page_webp(page: pymupdf.Page, width_px: int = 1600) -> bytes:
    zoom = width_px / page.rect.width
    pix = page.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), alpha=False)
    image = Image.frombytes("RGB", (pix.width, pix.height), pix.samples)
    buf = io.BytesIO()
    image.save(buf, "WEBP", quality=80)
    return buf.getvalue()


def render_pdf_page_webp(data: bytes, index: int, width_px: int = 1600) -> bytes:
    with pymupdf.open(stream=data, filetype="pdf") as doc:
        return render_page_webp(doc[index], width_px)
