import 'package:flutter/widgets.dart';

import '../models/canonical_chapter.dart';
import '../models/selection_state.dart';
import 'coordinate_conversion.dart';

/// Drives drag-to-select over the reader's page overlays and produces a
/// [SelectionState] per `P1-mobile-CLAUDE.md`'s "Selection behaviour".
///
/// **P1 simplification, documented deliberately rather than hidden:** the
/// canonical schema (`contracts/canonical_chapter.schema.json`) only carries
/// block-level `bbox`, not per-word or per-line geometry. So selection here
/// is **block-level** — dragging a marquee across the page selects whole
/// blocks whose bbox intersects the drag, and the highlight in
/// `bbox_overlay.dart` draws one rect per selected block rather than true
/// per-line rects. Real word-snap / per-line highlighting needs either (a)
/// pdfrx's own text-layer hit-testing wired in, which would compute
/// selection independently of the canonical schema, or (b) extending the
/// schema with line geometry — both are contract-level decisions for a
/// later phase, not something to bolt on unilaterally here.
///
/// Every page overlay calls [registerPageLayout] on each build (layouts
/// change with scroll/zoom) so a drag that crosses a page boundary can
/// still be resolved against every currently-visible page, not just the one
/// the gesture started on — see the class-level note in `reader_screen.dart`
/// for why plain widget-local gesture handling isn't enough for that.
class SelectionController extends ChangeNotifier {
  SelectionController(this._index);

  ChapterIndex _index;
  final Map<String, PageLayout> _pageLayouts = {};

  Offset? _dragStart;
  Offset? _dragCurrent;
  SelectionState? _selection;

  SelectionState? get selection => _selection;
  bool get isActive => _selection != null;

  void updateIndex(ChapterIndex index) {
    _index = index;
  }

  /// Called from `pageOverlaysBuilder` for every visible page, every build.
  /// [pageRect] must be on-screen, logical-pixel coordinates (what pdfrx
  /// hands the builder) — see `coordinate_conversion.dart`.
  ///
  /// Notifies listeners (deferred to after the current frame, since this is
  /// called *during* pdfrx's own build pass and calling `notifyListeners()`
  /// synchronously here would rebuild widgets mid-build) when a page's
  /// layout actually changes — i.e. on scroll/zoom, not on every drag-update
  /// frame, since drags don't cause pdfrx to re-invoke this callback. Used
  /// by the reader's dark-mode figure overlay to reposition itself when
  /// pages move, without needing its own separate notification channel.
  void registerPageLayout(String pageId, PageLayout layout) {
    final existing = _pageLayouts[pageId];
    _pageLayouts[pageId] = layout;
    if (existing == null || existing.pageRect != layout.pageRect || existing.rotation != layout.rotation) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  /// The last-registered on-screen layout for [pageId], if that page is
  /// currently visible (or was, as of the last frame it was).
  PageLayout? layoutFor(String pageId) => _pageLayouts[pageId];

  void startDrag(String originPageId, Offset localPosition) {
    final origin = _pageLayouts[originPageId];
    if (origin == null) return;
    _dragStart = origin.pageRect.topLeft + localPosition;
    _dragCurrent = _dragStart;
    _recompute();
  }

  void updateDrag(String originPageId, Offset localPosition) {
    final origin = _pageLayouts[originPageId];
    if (origin == null || _dragStart == null) return;
    _dragCurrent = origin.pageRect.topLeft + localPosition;
    _recompute();
  }

  void endDrag() {
    _dragStart = null;
    _dragCurrent = null;
    // _selection is left as the finalized result of the drag.
  }

  void clear() {
    if (_selection == null && _dragStart == null) return;
    _selection = null;
    _dragStart = null;
    _dragCurrent = null;
    notifyListeners();
  }

  void _recompute() {
    final start = _dragStart;
    final current = _dragCurrent;
    if (start == null || current == null) return;
    final dragRect = Rect.fromPoints(start, current);

    final touched = <ChapterBlock>[];
    for (final entry in _pageLayouts.entries) {
      final layout = entry.value;
      if (!dragRect.overlaps(layout.pageRect)) continue;
      for (final block in _index.blocksByPage[entry.key] ?? const <ChapterBlock>[]) {
        if (block.type == BlockType.header ||
            block.type == BlockType.footer ||
            block.type == BlockType.pageNumber) {
          continue; // chrome-ish blocks are never selectable
        }
        final blockRect = toScreen(block.bbox, layout);
        if (blockRect.overlaps(dragRect)) {
          touched.add(block);
        }
      }
    }

    if (touched.isEmpty) {
      _selection = null;
      notifyListeners();
      return;
    }

    touched.sort((a, b) => a.order.compareTo(b.order));

    final firstRect = toScreen(touched.first.bbox, _pageLayouts[touched.first.pageId]!);
    final lastRect = toScreen(touched.last.bbox, _pageLayouts[touched.last.pageId]!);
    var anchor = firstRect;
    for (final b in touched.skip(1)) {
      anchor = anchor.expandToInclude(toScreen(b.bbox, _pageLayouts[b.pageId]!));
    }

    _selection = SelectionState(
      text: touched.map((b) => b.text ?? '').where((t) => t.isNotEmpty).join(' '),
      blockIds: touched.map((b) => b.blockId).toList(growable: false),
      pageIds: touched.map((b) => b.pageId).toSet().toList(growable: false),
      anchorRect: anchor,
      firstBlockRect: firstRect,
      lastBlockRect: lastRect,
    );
    notifyListeners();
  }

  /// Selected block ids on [pageId], for the highlight painter.
  Set<String> selectedBlockIdsOn(String pageId) {
    final sel = _selection;
    if (sel == null) return const {};
    return sel.blockIds.where((id) => id.startsWith('${pageId}_')).toSet();
  }
}
