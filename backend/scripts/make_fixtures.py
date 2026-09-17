"""Hand-built canonical chapter fixtures for Dev A until the real pipeline produces them.

Run from repo root:  python backend/scripts/make_fixtures.py
Output is deterministic, so re-running produces no diff.
"""

import hashlib
import json
import sys
import uuid
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "backend"))

from app.ingest.layout import LayoutBlock, block_id, page_id, reading_order  # noqa: E402

OUT = ROOT / "contracts" / "fixtures"
A4 = (595.0, 842.0)
CREATED = "2026-09-14T10:00:00Z"

SENTENCES = [
    "All living organisms need energy to carry out the life processes that keep them alive.",
    "Nutrition is the process of taking in food and using it to obtain energy and build the body.",
    "Autotrophs such as green plants make their own food through photosynthesis.",
    "During photosynthesis, carbon dioxide and water are converted into carbohydrates using sunlight.",
    "Chlorophyll in the chloroplasts absorbs light energy needed for this reaction.",
    "Heterotrophs depend directly or indirectly on autotrophs for their food.",
    "In human beings, digestion begins in the mouth where saliva breaks down starch.",
    "Respiration releases the energy stored in food so that cells can use it.",
    "Aerobic respiration uses oxygen and produces carbon dioxide, water and energy.",
    "Transportation in plants happens through xylem and phloem tissues.",
]
HINDI = "पौधे प्रकाश संश्लेषण द्वारा अपना भोजन स्वयं बनाते हैं।"


def uid(name: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, f"notesapp-fixture/{name}"))


def text(seed: int, n: int = 3) -> str:
    return " ".join(SENTENCES[(seed + i) % len(SENTENCES)] for i in range(n))


def chapter(name: str, title: str, pages: list[dict[str, Any]], raw_blocks: list[list[dict[str, Any]]], **extra: Any) -> dict[str, Any]:
    """raw_blocks[page] = blocks without ids/order; assigns ids + global order via reading_order."""
    blocks: list[dict[str, Any]] = []
    order = 0
    for pi, page_blocks in enumerate(raw_blocks):
        pid = page_id(pi)
        ordered = reading_order([LayoutBlock(tuple(b["bbox"]), b) for b in page_blocks])  # type: ignore[arg-type]
        for bi, lb in enumerate(ordered):
            b: dict[str, Any] = lb.key  # type: ignore[assignment]
            order += 1
            blocks.append({"block_id": block_id(pid, bi), "page_id": pid, **b, "order": order})
    return {
        "schema_version": 1,
        "chapter_id": uid(name),
        "content_hash": hashlib.sha256(name.encode()).hexdigest(),
        "title": title,
        "source_filename": f"{name}.pdf",
        "language": extra.pop("language", "en"),
        "page_count": len(pages),
        "ocr_engine": extra.pop("ocr_engine", "pdf-text-layer"),
        "created_at": CREATED,
        "pages": pages,
        "blocks": blocks,
    }


def page(i: int, has_text_layer: bool, name: str) -> dict[str, Any]:
    return {
        "page_id": page_id(i),
        "index": i,
        "width_pt": A4[0],
        "height_pt": A4[1],
        "rotation": 0,
        "image_key": f"pages/{name}/{page_id(i)}.webp" if i < 10 else None,
        "has_text_layer": has_text_layer,
    }


def blk(type_: str, bbox: tuple[float, float, float, float], txt: str | None, level: int | None = None,
        confidence: float | None = None, image_key: str | None = None) -> dict[str, Any]:
    return {"type": type_, "text": txt, "bbox": [round(v, 4) for v in bbox], "level": level,
            "confidence": confidence, "image_key": image_key}


def furniture(i: int, header: str) -> list[dict[str, Any]]:
    return [
        blk("header", (0.1, 0.03, 0.9, 0.05), header),
        blk("page_number", (0.47, 0.95, 0.53, 0.97), str(i + 1)),
    ]


def clean() -> dict[str, Any]:
    name = "chapter_clean"
    pages, raw = [], []
    for i in range(60):
        pages.append(page(i, True, name))
        b = furniture(i, "Science — Life Processes")
        y = 0.08
        if i % 6 == 0:
            b.append(blk("heading", (0.1, y, 0.9, y + 0.04), f"{i // 6 + 1}. {SENTENCES[i % 10].split(' ')[0]} and life", level=1))
            y += 0.06
        b.append(blk("heading", (0.1, y, 0.7, y + 0.03), f"{i // 6 + 1}.{i % 6 + 1} Key ideas", level=2))
        y += 0.05
        b.append(blk("paragraph", (0.1, y, 0.9, y + 0.14), text(i)))
        y += 0.16
        if i % 4 == 1:
            b.append(blk("figure", (0.2, y, 0.8, y + 0.25), None, image_key=f"figures/{name}/{page_id(i)}_fig.webp"))
            y += 0.26
            b.append(blk("caption", (0.2, y, 0.8, y + 0.025), f"Figure {i // 4 + 1}: Cross-section of a leaf"))
            y += 0.05
        for k in range(3):
            b.append(blk("list_item", (0.12, y, 0.9, y + 0.03), f"{k + 1}. {SENTENCES[(i + k) % 10]}"))
            y += 0.04
        if i % 5 == 3:
            b.append(blk("formula", (0.3, y, 0.7, y + 0.04), "6CO2 + 12H2O → C6H12O6 + 6O2 + 6H2O"))
            y += 0.06
        b.append(blk("paragraph", (0.1, y, 0.9, min(y + 0.12, 0.93)), text(i + 5)))
        raw.append(b)
    return chapter(name, "Life Processes", pages, raw)


def scanned() -> dict[str, Any]:
    name = "chapter_scanned"
    pages, raw = [], []
    for i in range(8):
        pages.append(page(i, False, name))
        conf = round(0.55 + (i % 4) * 0.1, 2)
        b = [
            blk("heading", (0.12, 0.07, 0.75, 0.11), "Control and Coordination" if i == 0 else "Control and Coordinaton", level=1, confidence=conf),
            blk("paragraph", (0.1, 0.14, 0.88, 0.34), text(i).replace("e", "c", 2), confidence=round(conf - 0.1, 2)),
            blk("paragraph", (0.11, 0.37, 0.9, 0.52), HINDI if i % 3 == 0 else text(i + 2), confidence=round(conf - 0.15, 2)),
            blk("figure", (0.15, 0.55, 0.85, 0.82), None, image_key=f"figures/{name}/{page_id(i)}_fig.webp"),
            blk("caption", (0.15, 0.83, 0.85, 0.86), "Fig. Reflex arc (scanned)", confidence=0.41),
            blk("page_number", (0.46, 0.94, 0.54, 0.97), str(i + 1), confidence=0.9),
        ]
        raw.append(b)
    return chapter(name, "Control and Coordination", pages, raw, language="en", ocr_engine="surya-0.6")


def twocolumn() -> dict[str, Any]:
    name = "chapter_twocolumn"
    pages, raw = [], []
    for i in range(6):
        pages.append(page(i, True, name))
        b = furniture(i, "Journal of School Science")
        if i == 0:
            b.append(blk("heading", (0.08, 0.07, 0.92, 0.11), "Heredity and Evolution", level=1))
        top = 0.13 if i == 0 else 0.08
        # left column
        b.append(blk("heading", (0.08, top, 0.47, top + 0.03), f"Section {i + 1}A (left column, read first)", level=2))
        b.append(blk("paragraph", (0.08, top + 0.04, 0.47, top + 0.3), f"[L{i + 1}.1] " + text(i, 4)))
        b.append(blk("paragraph", (0.08, top + 0.32, 0.47, 0.58), f"[L{i + 1}.2] " + text(i + 3, 3)))
        # right column, slightly offset tops so naive y-sorting interleaves columns
        b.append(blk("heading", (0.53, top + 0.01, 0.92, top + 0.04), f"Section {i + 1}B (right column, read second)", level=2))
        b.append(blk("paragraph", (0.53, top + 0.05, 0.92, top + 0.25), f"[R{i + 1}.1] " + text(i + 6, 3)))
        b.append(blk("paragraph", (0.53, top + 0.27, 0.92, 0.58), f"[R{i + 1}.2] " + text(i + 1, 4)))
        # full-width figure splits the page, then another two-column band
        b.append(blk("figure", (0.1, 0.61, 0.9, 0.78), None, image_key=f"figures/{name}/{page_id(i)}_fig.webp"))
        b.append(blk("paragraph", (0.08, 0.81, 0.47, 0.92), f"[L{i + 1}.3] " + text(i + 2, 2)))
        b.append(blk("paragraph", (0.53, 0.8, 0.92, 0.92), f"[R{i + 1}.3] " + text(i + 4, 2)))
        raw.append(b)
    return chapter(name, "Heredity and Evolution", pages, raw)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for build in (clean, scanned, twocolumn):
        data = build()
        path = OUT / f"chapter_{build.__name__}.json"
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
        print(f"wrote {path.relative_to(ROOT)}  pages={data['page_count']} blocks={len(data['blocks'])}")


if __name__ == "__main__":
    main()
