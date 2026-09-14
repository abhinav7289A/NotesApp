# P1 — MOBILE: Reader and selection

OWNER: Dev A
DURATION: 2 weeks
STATUS: in progress
READ FIRST: `/CLAUDE.md`, `/contracts/canonical_chapter.schema.json`, `/COLLABORATION.md`, `/design/demo.html`

---

## Goal

Open a real 60-page chapter on a phone, scroll it at 60fps, drag across a paragraph, and get the correct `block_id`s back.

No AI. No annotations persisted. No notes editor. The action bar appears on selection and its buttons do nothing yet — that is P2.

---

## Why this phase matters more than it looks

Everything in this product hangs off one interaction: the user drags across text on a rendered PDF page and the app knows exactly which canonical blocks they touched. Get that wrong and every feature after it is built on sand.

The second thing: a reader that stutters loses the user in the first minute, before any AI has a chance to impress them. Performance here is a feature, not a polish task.

---

## Scope

### In
- Library screen: list documents from the API, tap to open
- Upload: pick a PDF, presigned PUT to R2, poll status, show honest progress
- Reader: `pdfrx`, page virtualization, smooth scroll, pinch zoom
- Transparent overlay aligned to the page, drawn from canonical `bbox` values
- Text selection: drag, handles, word snapping, multi-block, cross-page
- Floating action bar on selection — buttons present, wired to `debugPrint` only
- Light and dark reading modes, including page toning
- Chrome hide/reveal on tap

### Out (do not build)
The AI sheet. Persisted annotations. Ink or stylus. Notes editor. Quiz. Paywall. Auth beyond a hardcoded dev token. Region select (P5).

---

## Stack

```
Flutter 3.x, Dart 3.x
pdfrx                      # Pdfium-backed, page virtualization built in
flutter_riverpod           # state
drift                      # local SQLite cache of canonical JSON
dio + retrofit             # HTTP, generated from contracts/openapi.json
freezed + json_serializable
```

**Do not hand-write API models.** Generate from the contract:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If a backend field renames, your build breaks with a clear error instead of a null crash at runtime.

---

## Work against fixtures first

Dev B commits these by day 3:

```
contracts/fixtures/chapter_clean.json
contracts/fixtures/chapter_scanned.json
contracts/fixtures/chapter_twocolumn.json
```

Build everything against those files loaded from disk. Point at the real backend only in the Friday integration hour. You should never be blocked waiting for an endpoint.

Mock server when you need live HTTP:

```bash
npx @stoplight/prism mock contracts/openapi.json --port 4010
```

---

## The coordinate problem — read this twice

Canonical `bbox` is `[x0, y0, x1, y1]` normalized 0..1, origin top-left, relative to the **unrotated** page.

`pdfrx` gives you a rendered page rect in screen space that changes with scroll, zoom and device pixel ratio.

Write **one** conversion function. Every hit test, every highlight rect, every overlay goes through it. Do not scatter coordinate math across widgets — that is how alignment bugs become unfixable.

```dart
Rect toScreen(List<double> bbox, PageLayout layout) { ... }
List<double> toNormalized(Offset screenPoint, PageLayout layout) { ... }
```

Handle page `rotation` (0/90/180/270) inside these two functions and nowhere else.

**Verify alignment visually before building selection.** Add a debug toggle that strokes every block bbox in amber over the page. If those rectangles do not sit exactly on the text at 100% and 300% zoom, stop and fix it. Selection built on misaligned boxes will waste a week.

---

## Selection behaviour

- Long-press starts selection and snaps to the word under the finger
- Drag extends; two handles appear, each with a 44px hit area even though they render smaller
- Selection spans blocks and pages — collect every `block_id` whose bbox intersects the selection path, ordered by `order`
- Highlight rects are per-line, not one box around the whole span
- Tap outside clears
- Action bar floats above the selection, flipping below when near the top edge, never off-screen

Output on every selection change:

```dart
SelectionState(
  text: "...",
  blockIds: ["p00012_b004", "p00012_b005"],
  pageIds: ["p00012"],
  anchorRect: Rect,
)
```

That object is P2's entire input. Get its shape right now.

---

## Dark mode is a real problem here

Do not put dark chrome around a white scanned page. That contrast is painful at night, and night reading is a primary use case.

Tone the page itself: paper becomes `#20242B`, black ink becomes light grey, relative contrast preserved. Chrome sits at `#14161A`, slightly darker than the page.

Use a `ColorFilter` matrix on the rendered page, **not** a straight inversion — inversion turns photographs and coloured diagrams into negatives. If a block is `type: figure`, mask it out of the filter so images render normally.

This is genuinely hard and almost every PDF reader gets it wrong. Doing it well is a real reason someone switches to us.

---

## Colour tokens

| Role | Light | Dark |
|---|---|---|
| Page | `#FFFFFF` | `#20242B` |
| Chrome | `#EDF0F4` | `#14161A` |
| Ink | `#16181D` | `#E4E7EC` |
| Secondary | `#5A6472` | `#9AA3B0` |
| Hairline | `#D8DCE2` | `#343A44` |
| User accent | `#C77A00` | `#E8A33D` |
| AI accent | `#A8324A` | `#E07A93` |
| Selection fill | `#FFE9A8` @ 40% | `#4A3A14` @ 55% |

Amber means the user made it. Rose means AI made it. No sparkle icons, no AI badges, no purple gradients — hue carries the meaning.

Hairline borders at 0.5px. No shadows. Motion only in response to a touch.

---

## Performance targets — measured on a real mid-range Android, not an emulator

| | Target |
|---|---|
| Cold start to library | < 1.5s |
| Open a 60-page chapter | < 800ms to first page |
| Scroll | 60fps sustained, no jank frames |
| Pinch zoom | 60fps |
| Selection drag → highlight | < 16ms per frame |
| Memory, 500-page doc | < 250MB |

Keep at most 3 pages rendered at a time and dispose the rest. Cache decoded pages in an LRU of 5. Do the block hit test against a spatial index (simple grid buckets per page), not a linear scan of every block.

---

## Acceptance test — the gate

Do not start P2 until all of these pass on a physical device.

1. Library lists documents from the API and opens one
2. A 60-page chapter scrolls end to end at 60fps
3. Debug bbox overlay aligns exactly with text at 100% and 300% zoom
4. Long-press snaps to a word; drag extends across two paragraphs
5. A selection spanning a page boundary returns block IDs from both pages, in reading order
6. Selected `block_id`s printed to console match the canonical JSON by hand inspection — verify on 10 different selections
7. Action bar never renders off-screen, including at the very top and bottom of a page
8. Dark mode: page toned, diagrams still in colour, text comfortably readable at night
9. Two-column fixture: selection order follows reading order, not visual left-to-right across columns
10. Airplane mode: a previously opened chapter still renders from the local cache

Check 6 is the one that matters most. Do it properly and write down the results.

---

## Known traps

**Pdfium page coordinates have a bottom-left origin.** Canonical bbox is top-left. Flip `y` once, inside the conversion function, and add a test for it.

**Device pixel ratio** breaks alignment on high-DPI phones if you mix logical and physical pixels. Pick logical pixels everywhere and be consistent.

**`pdfrx` disposes page textures aggressively** under memory pressure. Do not hold a page reference across a scroll.

**Selection handles need a 44px hit area** even when the visual handle is 12px. Test with a real thumb, not a mouse in the simulator.

**Do not render PDFs server-side.** On-device Pdfium only. Server rendering makes every page turn a network round trip, kills offline reading, and the bandwidth bill scales with reading time.

---

## Definition of done

All ten acceptance checks pass on a physical mid-range Android, the coordinate conversion has unit tests, and you have opened a real chapter from Dev B's staging backend during a Friday integration hour.
