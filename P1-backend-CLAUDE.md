# P1 — BACKEND: Ingest and canonical JSON

OWNER: Dev B
DURATION: 2 weeks
STATUS: in progress
READ FIRST: `/CLAUDE.md`, `/contracts/canonical_chapter.schema.json`, `/COLLABORATION.md`

---

## Goal

Upload a real textbook PDF, process it in the background, and serve a canonical chapter JSON that validates against the frozen schema. Nothing else.

No AI. No agents. No generation. If you find yourself writing a prompt in this phase, stop — that is P4.

---

## Why this phase matters more than it looks

`block_id` and `page_id` are the anchors for every annotation, every AI answer, every cache entry, and every generated artifact for the life of this product. If their format or stability changes in week 6, every stored note detaches and every cache entry invalidates.

Treat the ID scheme as frozen concrete. Everything else in P1 can be rewritten later.

---

## Scope

### In
- Upload flow: presigned PUT to R2, register document, enqueue ingest job
- Ingest worker: detect text layer → extract, or fall back to OCR
- Build canonical chapter JSON, validate against the schema, persist
- Content-hash dedup: same bytes uploaded twice returns the existing chapter, no reprocessing
- Rasterize pages to WebP, store in R2, serve signed URLs
- Job status endpoint the client can poll
- `make db-reset` so Dev A can reset his local stack without asking you

### Out (do not build)
Auth beyond a hardcoded dev user. AI anything. Notes, quiz, chat, annotations, edit layer. Payments. Rate limiting. Admin UI.

---

## Stack

```
FastAPI + uvicorn (async)
ARQ on Redis for the queue          # simpler than Celery, enough for this
PyMuPDF (fitz)                      # inspection, text layer, rasterization
surya-ocr                           # CPU, fallback when no text layer
Supabase Postgres + SQLAlchemy 2.0 + Alembic
boto3 → Cloudflare R2 (S3-compatible)
pydantic v2 models as contract source of truth
```

Pin `surya` and `PyMuPDF` exactly. Both change output between minor versions, and output changes mean cache invalidation.

---

## Endpoints

```
POST   /v1/documents                 → {document_id, upload_url}
POST   /v1/documents/{id}/ingest     → {job_id}          enqueues
GET    /v1/documents/{id}            → {status, progress, page_count, error}
GET    /v1/documents/{id}/chapter    → CanonicalChapter
GET    /v1/pages/{page_id}/image     → 302 to signed R2 URL
GET    /v1/documents                 → list for the library screen
```

`status` is one of: `uploaded | processing | ready | failed`.
`progress` is 0–100, updated per page so the client can show something honest.

On failure, return a machine-readable `error.code` (`SCAN_TOO_POOR`, `ENCRYPTED_PDF`, `TOO_MANY_PAGES`, `CORRUPT_FILE`) plus a human message. Dev A renders a different screen per code — do not send only prose.

---

## The ingest pipeline

```
1. fetch from R2, sha256 the bytes
2. if content_hash exists and status=ready → return existing chapter_id, STOP
3. fitz.open → reject encrypted, reject >500 pages, reject >40MB
4. per page: page.get_text("dict")
     text layer present and sane  → use it, confidence=null
     absent or garbage            → rasterize at 200dpi → surya OCR
5. classify blocks (see below)
6. assign page_id, block_id, global reading order
7. normalize every bbox to 0..1
8. validate against canonical_chapter.schema.json — hard fail if invalid
9. persist chapter, rasterize pages to WebP at 1600px wide, upload to R2
10. status = ready
```

**Block classification** without an ML model, in this order: font size relative to the page median → heading and its level. A short line under a figure bbox → caption. Repeated text in the top or bottom 8% across pages → header/footer/page_number. Line starting with a bullet or `N.` → list_item. Everything else → paragraph. This is crude and correct enough; do not spend a week here.

**Reading order** on two-column pages is the one thing worth getting right. Detect columns by clustering x-midpoints, then sort within column, then concatenate. Wrong reading order makes every downstream summary incoherent.

---

## Database

```sql
documents(id, user_id, filename, content_hash, status, progress,
          page_count, error_code, created_at)
chapters(id, content_hash UNIQUE, schema_version, title, language,
         payload JSONB, ocr_engine, created_at)
pages(page_id PK, chapter_id, index, width_pt, height_pt, image_key)
jobs(id, document_id, type, state, attempts, last_error, created_at)
```

`chapters` is keyed on `content_hash`, not on user. Many documents point to one chapter. This is the whole cost model — do not add a `user_id` column to `chapters` for any reason.

Store the full canonical JSON in `payload` JSONB and serve it directly. Do not normalize blocks into their own table yet; you will only need that when search arrives, and premature normalization makes the read path slow for no benefit.

---

## Contract duties

You own `contracts/`. After any Pydantic model change:

```bash
./backend/scripts/gen_contract.sh   # regenerates contracts/openapi.json
```

Commit it in the same PR. CI fails if the committed file drifts from generated output.

**Before Dev A can start rendering, commit these by end of day 3:**

```
contracts/fixtures/chapter_clean.json     # born-digital textbook, 60 pages
contracts/fixtures/chapter_scanned.json   # photographed pages, low confidence
contracts/fixtures/chapter_twocolumn.json # the reading-order hard case
```

Hand-build them if the pipeline is not ready. Dev A is blocked without them, and a blocked teammate for three days costs more than a day of your time.

Add `examples=` to every Pydantic field so the prism mock server returns realistic data.

---

## Acceptance test — the gate

Do not start P2 until all of these pass.

1. Upload a real 60-page NCERT chapter → status reaches `ready` in under 4 minutes on a 2-vCPU box
2. The returned JSON validates against `canonical_chapter.schema.json` with zero errors
3. Upload the same file again → returns the existing `chapter_id` in under 2 seconds, no reprocessing
4. All three fixture PDFs process without a crash
5. On the two-column fixture, block `order` matches human reading order — verify by dumping text in order and reading it
6. Every bbox is within 0..1
7. `GET /v1/pages/{page_id}/image` returns a working signed URL that expires in 15 minutes
8. Kill the worker mid-job → restart → the job resumes or fails cleanly, never hangs in `processing`
9. `make db-reset` produces a working seeded database from scratch

Write 5 and 6 as pytest assertions over the fixtures, not as manual checks. They are your regression suite for the rest of the project.

---

## Known traps

**Scanned Indian textbooks are worse than you expect** — skew, shadows, show-through from the reverse page. Deskew and binarize before OCR or your confidence scores collapse.

**Devanagari and Gurmukhi OCR** needs the right surya language config. Test with a real bilingual chapter in week 1, not week 8.

**PyMuPDF text layers lie.** Some PDFs have a text layer that is garbage from a bad OCR pass upstream. Sanity check: if over 30% of extracted characters are non-alphanumeric noise, discard the layer and OCR instead.

**Do not rasterize all 500 pages eagerly.** Render the first 10 during ingest, the rest lazily on request, cached forever. The source is immutable so the cache never invalidates.

**Signed URLs are bearer tokens.** 15 minutes, re-issue on demand, never let the client cache them.

---

## Definition of done

All nine acceptance checks pass, fixtures are committed, `openapi.json` is current, and Dev A has successfully rendered a real chapter from your staging backend during a Friday integration hour.
