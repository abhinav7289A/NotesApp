# Contract changelog

2026-09-14  moved canonical_chapter.schema.json into contracts/. Added openapi.json with P1 endpoint stubs. — Dev A to set up Dart codegen.
2026-09-14  added fixtures chapter_clean (60p), chapter_scanned (8p, OCR confidence, Hindi), chapter_twocolumn (6p). Hand-built via backend/scripts/make_fixtures.py. — Dev A can build the reader against these.
2026-09-14  PROPOSED, needs Dev A review: page image route is now GET /v1/chapters/{chapter_id}/pages/{page_id}/image (was /v1/pages/{page_id}/image — page_id repeats in every chapter, so it cannot identify a page alone). Not yet shipped, so no deprecation window needed.
2026-09-14  added ErrorCode FILE_TOO_LARGE and INTERNAL_ERROR. 4xx bodies are {"detail": {"code", "message"}} (codes: NOT_FOUND, UPLOAD_MISSING, NOT_READY, FILE_TOO_LARGE). — Dev A: show a generic retry screen for any unknown code.
2026-09-14  CreateDocumentRequest.filename must end in .pdf (max 255 chars). DocumentSummary includes chapter_id once ready.
