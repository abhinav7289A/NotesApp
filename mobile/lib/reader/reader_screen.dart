import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../data/providers.dart';
import '../models/canonical_chapter.dart';
import '../theme/tokens.dart';
import 'action_bar.dart';
import 'bbox_overlay.dart';
import 'coordinate_conversion.dart';
import 'selection_controller.dart';

int _rotationToInt(PdfPageRotation r) => switch (r) {
      PdfPageRotation.none => 0,
      PdfPageRotation.clockwise90 => 90,
      PdfPageRotation.clockwise180 => 180,
      PdfPageRotation.clockwise270 => 270,
    };

String _pageIdFor(int pageNumber) => 'p${pageNumber.toString().padLeft(5, '0')}';

/// Tones the page for dark mode instead of inverting it — see
/// `P1-mobile-CLAUDE.md`'s "Dark mode is a real problem here". Paper maps to
/// the dark `page` token, ink maps to the light `ink` token, via a linear
/// per-channel remap (not a literal RGB invert, which would turn
/// photographs and coloured diagrams into negatives).
///
/// Known P1 gap, called out rather than silently skipped: the brief also
/// asks to mask `type: figure` blocks out of this filter so images stay in
/// color. Doing that correctly needs figure regions rendered as a separate,
/// unfiltered layer on top of the toned page — real work, and the brief
/// itself flags this as the hard part ("almost every PDF reader gets it
/// wrong"). This pass applies the tone uniformly; carving figures out is a
/// follow-up.
ColorFilter _toneFilter(AppColors dark) {
  double scale(int paper, int ink) => (paper - ink) / 255;
  return ColorFilter.matrix([
    scale(dark.page.r255, dark.ink.r255), 0, 0, 0, dark.ink.r255.toDouble(),
    0, scale(dark.page.g255, dark.ink.g255), 0, 0, dark.ink.g255.toDouble(),
    0, 0, scale(dark.page.b255, dark.ink.b255), 0, dark.ink.b255.toDouble(),
    0, 0, 0, 1, 0,
  ]);
}

extension on Color {
  int get r255 => (r * 255).round();
  int get g255 => (g * 255).round();
  int get b255 => (b * 255).round();
}

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.documentId, required this.title});

  final String documentId;
  final String title;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  SelectionController? _selectionController;
  bool _chromeVisible = true;
  Size _viewportSize = Size.zero;

  // Long-press-to-select is deliberately driven off raw `Listener` pointer
  // events rather than `GestureDetector.onLongPress*`. pdfrx's own docs warn
  // that a GestureDetector layered over each page "eats the gestures and
  // the viewer cannot handle them directly" — a plain GestureDetector enters
  // Flutter's gesture arena and competes with the viewer's own pan/zoom
  // recognizer for the pointer, which is what made touch-scrolling over page
  // content unreliable (only dragging outside the page overlay, e.g. near
  // the screen edge, scrolled reliably). `Listener` never joins the arena —
  // it observes every pointer event unconditionally — so the viewer's pan
  // recognizer is always completely free to claim a drag. We only decide
  // "this is a long-press-select, not a scroll" ourselves, via a timer.
  Timer? _longPressTimer;
  bool _selecting = false;
  int? _activePointerId;
  Offset? _pointerDownLocal;
  static const double _longPressSlop = 18; // matches Flutter's default kTouchSlop
  static const Duration _longPressDuration = Duration(milliseconds: 500);

  void _onPagePointerDown(String pageId, PointerDownEvent event) {
    if (_activePointerId != null) return; // a second finger (pinch-zoom) — ignore
    _activePointerId = event.pointer;
    _pointerDownLocal = event.localPosition;
    _selecting = false;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, () {
      final controller = _selectionController;
      final start = _pointerDownLocal;
      if (controller == null || start == null) return;
      _selecting = true;
      controller.startDrag(pageId, start);
    });
  }

  void _onPagePointerMove(String pageId, PointerMoveEvent event) {
    if (event.pointer != _activePointerId) return;
    if (_selecting) {
      _selectionController?.updateDrag(pageId, event.localPosition);
      return;
    }
    final start = _pointerDownLocal;
    if (start != null && (event.localPosition - start).distance > _longPressSlop) {
      // Real scroll/pan, not a held press — never enter selection mode, and
      // never having called any selection API, the viewer's own pan
      // recognizer is untouched and free to scroll normally.
      _longPressTimer?.cancel();
    }
  }

  void _onPagePointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;
    _longPressTimer?.cancel();
    final controller = _selectionController;
    if (_selecting) {
      controller?.endDrag();
    } else {
      final start = _pointerDownLocal;
      final moved = start != null && (event.localPosition - start).distance > _longPressSlop;
      if (!moved) {
        if (controller?.isActive ?? false) {
          controller!.clear();
        } else {
          setState(() => _chromeVisible = !_chromeVisible);
        }
      }
    }
    _selecting = false;
    _activePointerId = null;
    _pointerDownLocal = null;
  }

  void _onPagePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointerId) return;
    _longPressTimer?.cancel();
    _selecting = false;
    _activePointerId = null;
    _pointerDownLocal = null;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider(widget.documentId));
    final pdfFileAsync = ref.watch(localPdfFileProvider(widget.documentId));
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;
    final debugOverlay = ref.watch(debugBboxOverlayProvider);

    return Scaffold(
      backgroundColor: colors.chrome,
      body: chapterAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.amber)),
        error: (e, _) => _ErrorBody(message: 'Could not load chapter: $e', colors: colors),
        data: (chapter) {
          final controller = _selectionController ??= SelectionController(chapter);
          controller.updateChapter(chapter);

          return pdfFileAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: colors.amber)),
            error: (e, _) => _ErrorBody(message: 'Could not load PDF: $e', colors: colors),
            data: (file) => LayoutBuilder(
              builder: (context, constraints) {
                _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
                return _buildReader(chapter, file, controller, colors, debugOverlay, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReader(
    CanonicalChapter chapter,
    File file,
    SelectionController controller,
    AppColors colors,
    bool debugOverlay,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        Widget viewer = PdfViewer.file(
          file.path,
          initialPageNumber: 1,
          params: PdfViewerParams(
            backgroundColor: colors.chrome,
            margin: 10,
            pageDropShadow: null, // no shadows anywhere, per design tokens
            pageOverlaysBuilder: (context, pageRect, page) {
              final pageId = _pageIdFor(page.pageNumber);
              final rotation = _rotationToInt(page.rotation);
              controller.registerPageLayout(pageId, PageLayout(pageRect: pageRect, rotation: rotation));
              final blocksOnPage = chapter.blocksByPage[pageId] ?? const <ChapterBlock>[];

              return [
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (e) => _onPagePointerDown(pageId, e),
                    onPointerMove: (e) => _onPagePointerMove(pageId, e),
                    onPointerUp: _onPagePointerUp,
                    onPointerCancel: _onPagePointerCancel,
                    child: CustomPaint(
                      size: pageRect.size,
                      painter: ReaderPageOverlayPainter(
                        rotation: rotation,
                        blocksOnPage: blocksOnPage,
                        selection: controller.selection,
                        showDebugOverlay: debugOverlay,
                        colors: colors,
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
        );

        if (isDark) {
          viewer = ColorFiltered(colorFilter: _toneFilter(colors), child: viewer);
        }

        return Stack(
          children: [
            Positioned.fill(child: viewer),
            if (_chromeVisible) _TopBar(title: widget.title, colors: colors, debugOverlay: debugOverlay),
            if (_chromeVisible && !controller.isActive) _BottomBar(colors: colors),
            if (controller.selection != null)
              SelectionActionBar(
                selection: controller.selection!,
                viewportSize: _viewportSize,
                colors: colors,
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.title, required this.colors, required this.debugOverlay});
  final String title;
  final AppColors colors;
  final bool debugOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 48,
          color: colors.chrome,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colors.ink),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: AppText.navBarTitle(colors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Debug-only: strokes every block bbox in amber, per
              // `P1-mobile-CLAUDE.md`'s "add a debug toggle" for verifying
              // coordinate-conversion alignment at 100%/300% zoom. Not part
              // of the shipped reading UI — remove before this leaves P1.
              if (kDebugMode)
                IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: debugOverlay ? colors.amber : colors.ink2,
                  ),
                  tooltip: 'Debug bbox overlay',
                  onPressed: () => ref.read(debugBboxOverlayProvider.notifier).state = !debugOverlay,
                ),
              IconButton(
                icon: Icon(Icons.search, color: colors.ink2),
                onPressed: null, // out of P1 scope
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          color: colors.chrome,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text('Select text to ask, summarise or simplify',
              style: AppText.bodyChrome(colors.ink2)),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.colors});
  final String message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: AppText.bodyChrome(colors.ink2), textAlign: TextAlign.center),
      ),
    );
  }
}
