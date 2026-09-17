# Contract changelog

2026-09-15  Moved `canonical_chapter.schema.json` into `contracts/` (was loose at repo root) and
            added `contracts/fixtures/chapter_clean.json`, `chapter_scanned.json`,
            `chapter_twocolumn.json`. — Dev A (placeholder, pending Dev B review). These are
            hand-authored small fixtures (2-3 pages each) covering headings/paragraphs/lists/
            figures/captions, an OCR-confidence scanned case, and a two-column reading-order case.
            They unblock mobile dev per `P1-mobile-CLAUDE.md` but are **not** the real 60-page
            ingest-pipeline output Dev B owes per `P1-backend-CLAUDE.md` — replace when the real
            pipeline is ready, and validate against `canonical_chapter.schema.json` before merging.
