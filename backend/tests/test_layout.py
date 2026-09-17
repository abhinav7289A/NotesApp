import pytest

from app.ingest.layout import LayoutBlock, block_id, is_garbage_text, normalize_bbox, page_id, reading_order


def test_ids_are_frozen_format() -> None:
    assert page_id(0) == "p00001"
    assert page_id(11) == "p00012"
    assert block_id("p00012", 3) == "p00012_b004"
    with pytest.raises(ValueError):
        block_id("p00001", 999)


def test_normalize_bbox_clamps() -> None:
    assert normalize_bbox((59.5, 84.2, 535.5, 900), 595, 842) == (0.1, 0.1, 0.9, 1.0)


@pytest.mark.parametrize(
    ("text", "garbage"),
    [
        ("Photosynthesis is the process by which plants make food.", False),
        ("प्रकाश संश्लेषण वह प्रक्रिया है।", False),
        ("ਪ੍ਰਕਾਸ਼ ਸੰਸ਼ਲੇਸ਼ਣ", False),
        ("~#@^ ¬¦§ ~~ @@ ^^ ¤¤ a", True),
        ("   ", True),
    ],
)
def test_is_garbage_text(text: str, garbage: bool) -> None:
    assert is_garbage_text(text) is garbage


def test_reading_order_two_columns_with_full_width_title() -> None:
    title = LayoutBlock((0.1, 0.05, 0.9, 0.1), "title")
    l1 = LayoutBlock((0.08, 0.15, 0.48, 0.3), "L1")
    r1 = LayoutBlock((0.52, 0.15, 0.92, 0.3), "R1")
    l2 = LayoutBlock((0.08, 0.35, 0.48, 0.6), "L2")
    r2 = LayoutBlock((0.52, 0.32, 0.92, 0.5), "R2")
    fig = LayoutBlock((0.1, 0.65, 0.9, 0.9), "fig")
    got = [b.key for b in reading_order([r2, fig, l2, r1, title, l1])]
    assert got == ["title", "L1", "L2", "R1", "R2", "fig"]


def test_reading_order_page_furniture_does_not_break_columns() -> None:
    header = LayoutBlock((0.1, 0.03, 0.9, 0.05), "header")
    l1 = LayoutBlock((0.08, 0.8, 0.47, 0.9), "L")
    r1 = LayoutBlock((0.53, 0.79, 0.92, 0.9), "R")
    page_no = LayoutBlock((0.47, 0.95, 0.53, 0.97), "pn")
    got = [b.key for b in reading_order([page_no, r1, l1, header])]
    assert got == ["header", "L", "R", "pn"]


def test_reading_order_single_column() -> None:
    a = LayoutBlock((0.1, 0.1, 0.5, 0.2), "a")
    b = LayoutBlock((0.12, 0.3, 0.5, 0.4), "b")
    assert [x.key for x in reading_order([b, a])] == ["a", "b"]
