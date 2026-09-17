import pymupdf
import pytest

from app.ingest.build import detect_language
from app.ingest.pdf import IngestError, clean_text, extract_raw_page, open_pdf
from app.models import ErrorCode
from tests import pdfs


def test_rotated_page_bbox_is_relative_to_unrotated_page() -> None:
    with pymupdf.open(stream=pdfs.rotated_90(), filetype="pdf") as doc:
        page = extract_raw_page(doc[0], 0)
    assert page.rotation == 90
    assert (page.width_pt, page.height_pt) == (pdfs.W, pdfs.H)
    [block] = page.blocks
    x0, y0, x1, y1 = block.bbox
    # text was drawn at (60, 80) on the unrotated page: left edge ~0.1, near the top
    assert 0.08 < x0 < 0.12 and y0 < 0.1 and x1 > 0.4, block.bbox


def test_rotated_page_figure_bbox_is_relative_to_unrotated_page() -> None:
    with pymupdf.open(stream=pdfs.rotated_90_with_figure(), filetype="pdf") as doc:
        page = extract_raw_page(doc[0], 0)
    [figure] = [b for b in page.blocks if b.is_figure]
    # image was placed at (60, 80, 260, 380) on the unrotated 595x842 page
    assert figure.bbox == pytest.approx((60 / 595, 80 / 842, 260 / 595, 380 / 842), abs=1e-3)


def test_open_pdf_errors() -> None:
    with pytest.raises(IngestError) as e:
        open_pdf(pdfs.encrypted(), 500)
    assert e.value.code == ErrorCode.ENCRYPTED_PDF
    with pytest.raises(IngestError) as e:
        open_pdf(pdfs.one_column(3), 2)
    assert e.value.code == ErrorCode.TOO_MANY_PAGES
    with pytest.raises(IngestError) as e:
        open_pdf(b"garbage", 500)
    assert e.value.code == ErrorCode.CORRUPT_FILE


def test_no_text_page_needs_ocr() -> None:
    with pymupdf.open(stream=pdfs.no_text(1), filetype="pdf") as doc:
        assert extract_raw_page(doc[0], 0).has_text_layer is False


@pytest.mark.parametrize(("text", "lang"), [("Life processes", "en"), ("जीवन प्रक्रियाएँ", "hi"), ("ਜੀਵਨ ਪ੍ਰਕਿਰਿਆਵਾਂ", "pa")])
def test_detect_language(text: str, lang: str) -> None:
    assert detect_language(text) == lang


def test_clean_text_strips_control_chars() -> None:
    # Seen in a real arXiv PDF: math glyphs extracted as \x00/\x01, which Postgres jsonb rejects.
    cleaned = clean_text("\x00 log pbeg j + log pend j \x01 (1.24)")
    assert "\x00" not in cleaned and "\x01" not in cleaned
    assert clean_text("tab\tstays") == "tab\tstays"
