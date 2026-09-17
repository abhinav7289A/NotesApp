"""Build small real PDFs in memory for pipeline tests."""

import io

import pymupdf

W, H = 595.0, 842.0
BODY = (
    "All living organisms need energy to carry out life processes. Nutrition is the process of taking in food "
    "and using it to obtain energy. Green plants make their own food through photosynthesis."
)


def _furniture(page: pymupdf.Page, n: int) -> None:
    page.insert_text((60, 30), "Science Textbook - Life Processes", fontsize=8)
    page.insert_text((290, 825), str(n), fontsize=8)


def one_column(pages: int = 3) -> bytes:
    doc = pymupdf.open()
    for i in range(pages):
        page = doc.new_page(width=W, height=H)
        _furniture(page, i + 1)
        page.insert_text((60, 90), f"Chapter part {i + 1}", fontsize=22)
        page.insert_textbox(pymupdf.Rect(60, 120, 535, 260), BODY, fontsize=11)
        page.insert_textbox(pymupdf.Rect(60, 280, 535, 300), "1. Plants are autotrophs", fontsize=11)
        page.insert_textbox(pymupdf.Rect(60, 310, 535, 450), BODY, fontsize=11)
    return doc.tobytes()


def two_column(pages: int = 2) -> bytes:
    doc = pymupdf.open()
    for i in range(pages):
        page = doc.new_page(width=W, height=H)
        _furniture(page, i + 1)
        page.insert_textbox(pymupdf.Rect(50, 100, 285, 400), f"LEFT{i}A " + BODY, fontsize=10)
        page.insert_textbox(pymupdf.Rect(310, 95, 545, 380), f"RIGHT{i}A " + BODY, fontsize=10)
        page.insert_textbox(pymupdf.Rect(50, 420, 285, 700), f"LEFT{i}B " + BODY, fontsize=10)
        page.insert_textbox(pymupdf.Rect(310, 400, 545, 700), f"RIGHT{i}B " + BODY, fontsize=10)
    return doc.tobytes()


def no_text(pages: int = 2) -> bytes:
    doc = pymupdf.open()
    for _ in range(pages):
        page = doc.new_page(width=W, height=H)
        page.draw_rect(pymupdf.Rect(50, 50, 545, 792), color=(0, 0, 0), fill=(0.9, 0.9, 0.9))
    return doc.tobytes()


def encrypted() -> bytes:
    doc = pymupdf.open()
    doc.new_page().insert_text((72, 72), "secret")
    return doc.tobytes(encryption=pymupdf.PDF_ENCRYPT_AES_256, owner_pw="owner", user_pw="user")


def rotated_90_with_figure() -> bytes:
    from PIL import Image

    buf = io.BytesIO()
    Image.new("RGB", (200, 300), "red").save(buf, "PNG")
    doc = pymupdf.open()
    page = doc.new_page(width=W, height=H)
    page.insert_image(pymupdf.Rect(60, 80, 260, 380), stream=buf.getvalue())
    page.set_rotation(90)
    return doc.tobytes()


def rotated_90() -> bytes:
    doc = pymupdf.open()
    page = doc.new_page(width=W, height=H)
    page.insert_text((60, 80), "Top left text on the unrotated page", fontsize=12)
    page.set_rotation(90)
    return doc.tobytes()
