import 'package:flutter/widgets.dart';

import '../models/canonical_chapter.dart';
import '../models/selection_state.dart';
import '../theme/tokens.dart';
import 'coordinate_conversion.dart';

/// Paints, for a single page:
/// - the debug bbox overlay (every block outlined in amber) when
///   [showDebugOverlay] is on — see `P1-mobile-CLAUDE.md`: "Verify alignment
///   visually before building selection... if those rectangles do not sit
///   exactly on the text at 100% and 300% zoom, stop and fix it."
/// - the selection highlight fill *and* a 1px amber outline ring for any
///   selected blocks on this page, per the design's selected-paragraph spec.
///
/// The two selection handles are **not** drawn here — they're separate,
/// animated widgets positioned in `reader_screen.dart` from
/// `SelectionState.firstBlockRect`/`lastBlockRect`, since a `CustomPainter`
/// has no widget lifecycle to hook an entrance animation to. They're also
/// **not yet independently draggable** in this first pass — only the
/// initial long-press-drag creates/extends a selection. Dragging from a
/// handle to adjust one end of an existing selection is a follow-up, noted
/// rather than silently skipped.
class ReaderPageOverlayPainter extends CustomPainter {
  ReaderPageOverlayPainter({
    required this.rotation,
    required this.blocksOnPage,
    required this.selection,
    required this.showDebugOverlay,
    required this.colors,
  });

  /// Only the rotation is needed here — the painter always works in the
  /// page's own local (0,0)-origin space (see [_localLayout]), since the
  /// canvas it paints on is already positioned at the page's on-screen
  /// location by pdfrx.
  final int rotation;
  final List<ChapterBlock> blocksOnPage;
  final SelectionState? selection;
  final bool showDebugOverlay;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final selectedIds = selection == null
        ? const <String>{}
        : selection!.blockIds.toSet();

    if (showDebugOverlay) {
      final debugPaint = Paint()
        ..color = colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (final block in blocksOnPage) {
        // toScreen expects the page's own local rect starting at (0,0);
        // the painter's canvas is already clipped/offset to the page, so
        // paint using a layout whose pageRect matches the painter's local
        // (0,0)-origin size, not the page's global on-screen position.
        canvas.drawRect(toScreen(block.bbox, _localLayout(size)), debugPaint);
      }
    }

    if (selectedIds.isEmpty) return;

    final fillPaint = Paint()
      ..color = colors.selectionFill
      ..style = PaintingStyle.fill;
    // Per the design's selected-paragraph spec: a 1px amber outline ring
    // around each selected block, on top of the fill. Stroked per-block
    // rather than once around the whole selection's bounding box, so a
    // multi-line / non-contiguous selection reads correctly instead of one
    // rectangle spanning gaps that weren't actually selected.
    final outlinePaint = Paint()
      ..color = colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final block in blocksOnPage) {
      if (!selectedIds.contains(block.blockId)) continue;
      final rect = toScreen(block.bbox, _localLayout(size));
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, outlinePaint);
    }
  }

  PageLayout _localLayout(Size size) =>
      PageLayout(pageRect: Offset.zero & size, rotation: rotation);

  @override
  bool shouldRepaint(covariant ReaderPageOverlayPainter oldDelegate) {
    return oldDelegate.selection != selection ||
        oldDelegate.showDebugOverlay != showDebugOverlay ||
        oldDelegate.blocksOnPage != blocksOnPage ||
        oldDelegate.rotation != rotation ||
        oldDelegate.colors != colors;
  }
}
