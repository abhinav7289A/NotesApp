"""Pure layout helpers for the ingest pipeline. No I/O — every function here is unit tested.

The ID formats below are FROZEN. Changing them detaches every stored annotation.
"""

import unicodedata
from collections.abc import Sequence
from dataclasses import dataclass

Bbox = tuple[float, float, float, float]

# Common punctuation is normal text, not noise.
_PUNCT_OK = set(".,;:!?'\"()[]-–—/%&+=*°·•‘’“”…|")


def page_id(index: int) -> str:
    """0-based page index → 'p00001'."""
    if not 0 <= index < 99_999:
        raise ValueError(f"page index out of range: {index}")
    return f"p{index + 1:05d}"


def block_id(page: str, index_in_page: int) -> str:
    """0-based block index within a page → 'p00001_b001'."""
    if not 0 <= index_in_page < 999:
        raise ValueError(f"block index out of range: {index_in_page}")
    return f"{page}_b{index_in_page + 1:03d}"


def normalize_bbox(rect: Sequence[float], width_pt: float, height_pt: float) -> Bbox:
    """Absolute PDF points (top-left origin, as PyMuPDF returns) → clamped 0..1."""
    x0, y0, x1, y1 = rect

    def clamp(v: float) -> float:
        return round(min(max(v, 0.0), 1.0), 5)

    return (clamp(x0 / width_pt), clamp(y0 / height_pt), clamp(x1 / width_pt), clamp(y1 / height_pt))


def is_garbage_text(text: str, threshold: float = 0.30) -> bool:
    """True when over `threshold` of non-space characters are noise — a bad upstream OCR layer.

    Letters, digits, combining marks (Devanagari/Gurmukhi matras) and common punctuation count as real text.
    """
    chars = [c for c in text if not c.isspace()]
    if not chars:
        return True
    noise = sum(1 for c in chars if not (c.isalnum() or c in _PUNCT_OK or unicodedata.category(c).startswith("M")))
    return noise / len(chars) > threshold


@dataclass
class LayoutBlock:
    bbox: Bbox
    key: object = None  # caller's handle, carried through sorting


def reading_order(blocks: Sequence[LayoutBlock], full_width: float = 0.55, margin: float = 0.08) -> list[LayoutBlock]:
    """Order blocks on one page for human reading, handling two-column layouts.

    Blocks entirely inside the top/bottom `margin` (running headers, footers, page numbers) are read
    first/last and never take part in column detection — a centred page number would otherwise skew the gutter.
    Blocks wider than `full_width` (titles, full-width figures) split the page into bands.
    Within a band, blocks are clustered into columns by x-midpoint, read column by column, top to bottom.
    """
    top = [b for b in blocks if b.bbox[3] <= margin]
    bottom = [b for b in blocks if b.bbox[1] >= 1 - margin and b not in top]
    body = [b for b in blocks if b not in top and b not in bottom]
    ordered: list[LayoutBlock] = sorted(top, key=lambda b: (b.bbox[1], b.bbox[0]))
    band: list[LayoutBlock] = []

    def flush() -> None:
        if not band:
            return
        mids = sorted((b.bbox[0] + b.bbox[2]) / 2 for b in band)
        # split columns at the largest gap between x-midpoints, if it is a real gutter
        gaps = [(mids[i + 1] - mids[i], i) for i in range(len(mids) - 1)]
        gap, at = max(gaps, default=(0.0, 0))
        if gap > 0.2:
            split = (mids[at] + mids[at + 1]) / 2
            left = [b for b in band if (b.bbox[0] + b.bbox[2]) / 2 < split]
            right = [b for b in band if (b.bbox[0] + b.bbox[2]) / 2 >= split]
            columns = [left, right]
        else:
            columns = [band]
        for col in columns:
            ordered.extend(sorted(col, key=lambda b: (b.bbox[1], b.bbox[0])))
        band.clear()

    for b in sorted(body, key=lambda b: (b.bbox[1], b.bbox[0])):
        if b.bbox[2] - b.bbox[0] > full_width:
            flush()
            ordered.append(b)
        else:
            band.append(b)
    flush()
    ordered.extend(sorted(bottom, key=lambda b: (b.bbox[1], b.bbox[0])))
    return ordered
