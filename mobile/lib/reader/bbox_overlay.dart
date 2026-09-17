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
/// - the selection highlight fill for any selected blocks on this page
/// - the two selection handles, if the overall selection's first/last block
///   happens to be on this page
///
/// Handles are drawn per the design spec (13px visible circle inside a 44px
/// touch target) but are **not yet independently draggable** in this first
/// pass — only the initial long-press-drag creates/extends a selection.
/// Dragging from a handle to adjust one end of an existing selection is a
/// follow-up, noted rather than silently skipped.
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

    Rect? first;
    Rect? last;
    for (final block in blocksOnPage) {
      if (!selectedIds.contains(block.blockId)) continue;
      final rect = toScreen(block.bbox, _localLayout(size));
      canvas.drawRect(rect, fillPaint);
      if (block.blockId == selection!.blockIds.first) first = rect;
      if (block.blockId == selection!.blockIds.last) last = rect;
    }

    final handlePaint = Paint()..color = colors.amber;
    if (first != null) {
      canvas.drawCircle(first.bottomLeft, 6.5, handlePaint);
    }
    if (last != null) {
      canvas.drawCircle(last.bottomRight, 6.5, handlePaint);
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
