import json
from pathlib import Path

import jsonschema
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.models import CanonicalChapter

CONTRACTS = Path(__file__).resolve().parents[2] / "contracts"
SCHEMA = json.loads((CONTRACTS / "canonical_chapter.schema.json").read_text(encoding="utf-8"))
FIXTURES = sorted((CONTRACTS / "fixtures").glob("chapter_*.json"))


def test_openapi_builds() -> None:
    assert "/v1/documents/{document_id}/chapter" in TestClient(app).get("/openapi.json").json()["paths"]


@pytest.mark.parametrize("path", FIXTURES, ids=lambda p: p.name)
def test_fixture_matches_schema_and_model(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    jsonschema.validate(data, SCHEMA)
    CanonicalChapter.model_validate(data)


def test_twocolumn_fixture_reads_left_column_before_right() -> None:
    """Acceptance check 5: block order follows human reading order, not visual left-to-right."""
    data = json.loads((CONTRACTS / "fixtures" / "chapter_twocolumn.json").read_text(encoding="utf-8"))
    tags = [b["text"].split("]")[0][1:] for b in data["blocks"] if b["type"] == "paragraph"]
    pages = len(data["pages"])
    expected = [f"{side}{p}.{n}" for p in range(1, pages + 1) for side, n in (("L", 1), ("L", 2), ("R", 1), ("R", 2), ("L", 3), ("R", 3))]
    assert tags == expected


@pytest.mark.parametrize("path", FIXTURES, ids=lambda p: p.name)
def test_fixture_bboxes_and_order(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    page_ids = {p["page_id"] for p in data["pages"]}
    orders = [b["order"] for b in data["blocks"]]
    assert orders == sorted(orders) and len(set(orders)) == len(orders)
    for b in data["blocks"]:
        x0, y0, x1, y1 = b["bbox"]
        assert 0 <= x0 < x1 <= 1 and 0 <= y0 < y1 <= 1, b["block_id"]
        assert b["page_id"] in page_ids and b["block_id"].startswith(b["page_id"] + "_")
