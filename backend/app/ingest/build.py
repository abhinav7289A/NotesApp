"""Raw extracted pages → canonical chapter JSON. Pure: no PDF library, no I/O except loading the schema once."""

import json
import re
from collections import Counter
from dataclasses import dataclass, field
from datetime import datetime
from functools import lru_cache
from pathlib import Path
from typing import Any, cast
from uuid import UUID

import jsonschema

from app.config import REPO_ROOT
from app.ingest.layout import Bbox, LayoutBlock, block_id, page_id, reading_order
from app.models import CanonicalChapter

SCHEMA_PATH: Path = REPO_ROOT / "contracts" / "canonical_chapter.schema.json"
MARGIN = 0.08  # top/bottom band where running headers, footers and page numbers live

_LIST_RE = re.compile(r"^\s*(?:[•●◦▪‣∙*\-–]|\(?\d{1,3}[.)]|\(?[a-zA-Z][.)]|\(?[ivxIVX]{1,4}[.)])\s+")
_CAPTION_RE = re.compile(r"^\s*(?:fig\.?|figure|table|chart|चित्र|सारणी)\s*[\dA-Za-z]*[\d.:\-]", re.IGNORECASE)
_PAGE_NUMBER_RE = re.compile(r"^\s*(?:page\s*)?(?:\d{1,4}|[ivxlc]{1,6})\s*$", re.IGNORECASE)


@dataclass
class RawBlock:
    bbox: Bbox  # normalized 0..1, top-left origin, unrotated page
    text: str | None  # None for figures
    font_size: float = 0.0
    is_figure: bool = False


@dataclass
class RawPage:
    index: int
    width_pt: float
    height_pt: float
    rotation: int
    has_text_layer: bool
    blocks: list[RawBlock] = field(default_factory=list)


def _in_margin(b: RawBlock) -> bool:
    mid = (b.bbox[1] + b.bbox[3]) / 2
    return mid < MARGIN or mid > 1 - MARGIN


def _margin_key(text: str) -> str:
    return re.sub(r"\d+", "#", text.strip().lower())[:80]


def _repeated_margin_texts(pages: list[RawPage]) -> set[str]:
    """Text that recurs in the top/bottom margin across pages, digits ignored → running header/footer."""
    if len(pages) < 2:
        return set()
    counts: Counter[str] = Counter()
    for p in pages:
        counts.update({_margin_key(b.text) for b in p.blocks if b.text and _in_margin(b)})
    threshold = max(2, round(0.3 * len(pages)))
    return {k for k, n in counts.items() if n >= threshold}


def _weighted_median_font_size(blocks: list[RawBlock]) -> float:
    weighted = sorted((b.font_size, len(b.text or "")) for b in blocks if b.text and not _in_margin(b))
    total = sum(w for _, w in weighted)
    running = 0
    for size, w in weighted:
        running += w
        if running * 2 >= total:
            return size
    return 0.0


def _below_figure(b: RawBlock, figures: list[RawBlock]) -> bool:
    for f in figures:
        overlaps = min(b.bbox[2], f.bbox[2]) - max(b.bbox[0], f.bbox[0]) > 0
        if overlaps and 0 <= b.bbox[1] - f.bbox[3] <= 0.03:
            return True
    return False


def classify_page(page: RawPage, furniture: set[str]) -> list[tuple[RawBlock, str, int | None]]:
    """Crude, ordered rules from the P1 brief: size → heading, under figure → caption, margin repeats → header/footer, bullets → list."""
    median = _weighted_median_font_size(page.blocks)
    figures = [b for b in page.blocks if b.is_figure]
    out: list[tuple[RawBlock, str, int | None]] = []
    for b in page.blocks:
        if b.is_figure or b.text is None:
            out.append((b, "figure", None))
            continue
        text = b.text
        if _in_margin(b) and _PAGE_NUMBER_RE.match(text):
            out.append((b, "page_number", None))
        elif _in_margin(b) and _margin_key(text) in furniture:
            out.append((b, "header" if b.bbox[1] < 0.5 else "footer", None))
        elif len(text) < 300 and (_CAPTION_RE.match(text) or (len(text) < 200 and _below_figure(b, figures))):
            out.append((b, "caption", None))
        elif median and b.font_size >= median * 1.15 and len(text) <= 200:
            ratio = b.font_size / median
            out.append((b, "heading", 1 if ratio >= 1.6 else 2 if ratio >= 1.3 else 3))
        elif _LIST_RE.match(text):
            out.append((b, "list_item", None))
        else:
            out.append((b, "paragraph", None))
    return out


def detect_language(text: str) -> str:
    """BCP-47 guess from script: Devanagari → hi, Gurmukhi → pa, otherwise en."""
    deva = sum(1 for c in text if "ऀ" <= c <= "ॿ")
    guru = sum(1 for c in text if "਀" <= c <= "੿")
    letters = sum(1 for c in text if c.isalpha()) or 1
    if deva / letters > 0.3:
        return "hi"
    if guru / letters > 0.3:
        return "pa"
    return "en"


def build_chapter(
    pages: list[RawPage],
    *,
    chapter_id: UUID,
    content_hash: str,
    filename: str,
    created_at: datetime,
    ocr_engine: str = "pdf-text-layer",
) -> dict[str, Any]:
    furniture = _repeated_margin_texts(pages)
    pages_out: list[dict[str, Any]] = []
    blocks_out: list[dict[str, Any]] = []
    order = 0
    title: str | None = None

    for p in pages:
        pid = page_id(p.index)
        pages_out.append({
            "page_id": pid,
            "index": p.index,
            "width_pt": round(p.width_pt, 2),
            "height_pt": round(p.height_pt, 2),
            "rotation": p.rotation,
            "image_key": None,
            "has_text_layer": p.has_text_layer,
        })
        typed = classify_page(p, furniture)
        ordered = reading_order([LayoutBlock(b.bbox, i) for i, (b, _, _) in enumerate(typed)])
        for n, lb in enumerate(ordered):
            b, kind, level = typed[cast(int, lb.key)]
            order += 1
            if kind == "heading" and title is None:
                title = b.text
            blocks_out.append({
                "block_id": block_id(pid, n),
                "page_id": pid,
                "type": kind,
                "text": b.text,
                "bbox": list(b.bbox),
                "order": order,
                "level": level,
                "confidence": None,
                "image_key": None,
            })

    all_text = " ".join(b["text"] for b in blocks_out if b["text"])
    return {
        "schema_version": 1,
        "chapter_id": str(chapter_id),
        "content_hash": content_hash,
        "title": (title or Path(filename).stem)[:200],
        "source_filename": filename,
        "language": detect_language(all_text),
        "page_count": len(pages_out),
        "ocr_engine": ocr_engine,
        "created_at": created_at.isoformat(),
        "pages": pages_out,
        "blocks": blocks_out,
    }


@lru_cache
def _validator() -> jsonschema.Draft202012Validator:
    return jsonschema.Draft202012Validator(json.loads(SCHEMA_PATH.read_text(encoding="utf-8")))


def validate_chapter(payload: dict[str, Any]) -> None:
    """Hard fail on anything the frozen schema or the API model rejects."""
    _validator().validate(payload)
    CanonicalChapter.model_validate(payload)
