import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

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
/// This filter is applied to the *whole* rendered page (see `_buildReader`,
/// where it wraps the entire `PdfViewer`, overlays included) — Flutter's
/// `ColorFiltered` has no way to exempt a sub-region of its child. `figure`
/// blocks are kept in full color despite that by rendering them a second
/// time, unfiltered, at `_figureCropImage`, and compositing that crop in a
/// separate layer *outside* this `ColorFiltered` wrapper — see the
/// `if (isDark) ListenableBuilder(...)` block in `_buildReader`.
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

  // Long-press-to-select is driven off raw `Listener` pointer events rather
  // than `GestureDetector.onLongPress*`, so we can decide for ourselves
  // whether a touch is a long-press-select or a scroll/pinch, via a timer,
  // without adding a competing recognizer to the gesture arena.
  //
  // That alone isn't sufficient, though — see the `IgnorePointer` wrapped
  // around the `CustomPaint` below for the other half of the fix, which is
  // the one that actually mattered for pdfrx's own pan/zoom working at all.
  Timer? _longPressTimer;
  bool _selecting = false;
  int? _activePointerId;
  Offset? _pointerDownLocal;
  static const double _longPressSlop = 18; // matches Flutter's default kTouchSlop
  static const Duration _longPressDuration = Duration(milliseconds: 500);

  // Dark-mode figure masking (see `_toneFilter`'s doc comment): pdfrx's
  // `PdfPage` objects handed to `pageOverlaysBuilder` for each visible page,
  // kept around so figure crops can be rendered independent of that
  // callback's own rebuild cycle. Populated as a side effect of building,
  // same pattern already used for `SelectionController.registerPageLayout`.
  final Map<String, PdfPage> _pdfPages = {};
  // Rendered, unfiltered crops for `figure`-type blocks, keyed by blockId.
  // Cached for the screen's lifetime — chapters/pages don't change, and a
  // single high-resolution render (see `_figureRenderScale`) stays sharp
  // across the zoom range the P1 acceptance gate cares about (100%-300%),
  // so there's no need to re-render per zoom level.
  final Map<String, Future<ui.Image>> _figureImageCache = {};
  static const double _figureRenderScale = 3;

  void _onPagePointerDown(String pageId, PointerDownEvent event) {
    if (_activePointerId != null) {
      _longPressTimer?.cancel(); // a second finger down means pinch-zoom, never selection
      return;
    }
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
    _selectionController?.dispose();
    for (final pending in _figureImageCache.values) {
      pending.then((image) => image.dispose(), onError: (_) {});
    }
    super.dispose();
  }

  /// Renders a `figure` block's own region of its page at a fixed high
  /// resolution, independent of the page's dark-mode tone filter — see
  /// `_toneFilter`'s doc comment for why this needs to exist at all, and
  /// `_buildReader` for why it's composited *outside* the `ColorFiltered`
  /// wrapper rather than alongside `pageOverlaysBuilder`'s other content.
  ///
  /// Renders at rotation 0 (unrotated): `block.bbox` is defined relative to
  /// the unrotated page (per the canonical schema), and rotated-page figures
  /// aren't specially handled here — a known, narrow follow-up rather than
  /// a silent gap, since real-world rotated pages are rare in these fixtures.
  Future<ui.Image> _figureCropImage(ChapterBlock block, PdfPage page) {
    return _figureImageCache.putIfAbsent(block.blockId, () async {
      final fullWidth = page.width * _figureRenderScale;
      final fullHeight = page.height * _figureRenderScale;
      final bbox = block.bbox;
      final x = (bbox[0] * fullWidth).round();
      final y = (bbox[1] * fullHeight).round();
      final w = ((bbox[2] - bbox[0]) * fullWidth).round().clamp(1, fullWidth.round());
      final h = ((bbox[3] - bbox[1]) * fullHeight).round().clamp(1, fullHeight.round());

      final pdfImage = await page.render(
        x: x,
        y: y,
        width: w,
        height: h,
        fullWidth: fullWidth,
        fullHeight: fullHeight,
        rotationOverride: PdfPageRotation.none,
      );
      if (pdfImage == null) {
        throw StateError('pdfrx could not render a crop for ${block.blockId}');
      }
      try {
        return await pdfImage.createImage();
      } finally {
        pdfImage.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterIndexAsync = ref.watch(chapterIndexProvider(widget.documentId));
    final pdfFileAsync = ref.watch(localPdfFileProvider(widget.documentId));
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
        (ref.watch(themeModeProvider) == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;
    final debugOverlay = ref.watch(debugBboxOverlayProvider);

    return Scaffold(
      backgroundColor: colors.chrome,
      body: chapterIndexAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.amber)),
        error: (e, _) => _ErrorBody(message: 'Could not load chapter: $e', colors: colors),
        data: (index) {
          final controller = _selectionController ??= SelectionController(index);
          controller.updateIndex(index);

          return pdfFileAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: colors.amber)),
            error: (e, _) => _ErrorBody(message: 'Could not load PDF: $e', colors: colors),
            data: (file) => LayoutBuilder(
              builder: (context, constraints) {
                _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
                return _buildReader(index, file, controller, colors, debugOverlay, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  /// Deliberately **not** wrapped in an `AnimatedBuilder`/`ListenableBuilder`
  /// at this level. `SelectionController` calls `notifyListeners()` on every
  /// pointer-move frame during a selection drag — wrapping the whole
  /// `PdfViewer` construction in a listenable scope here used to mean every
  /// one of those frames rebuilt the entire viewer, including pdfrx's own
  /// internal pan/zoom state, which was the dominant cause of dragging-to-
  /// select feeling laggy. Instead, only the small selection-dependent
  /// widgets below (the per-page overlay painter, the bottom bar, the action
  /// bar) each get their own narrow `ListenableBuilder`, so a drag frame only
  /// rebuilds those, not the viewer.
  Widget _buildReader(
    ChapterIndex index,
    File file,
    SelectionController controller,
    AppColors colors,
    bool debugOverlay,
    bool isDark,
  ) {
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
          _pdfPages[pageId] = page;
          final blocksOnPage = index.blocksByPage[pageId] ?? const <ChapterBlock>[];

          return [
            Positioned.fill(
              child: Listener(
                // Deliberately translucent, but that alone doesn't stop
                // this overlay from blocking pdfrx's own pan/zoom
                // underneath: `CustomPaint` reports a hit test match for
                // every point inside its bounds regardless of what it
                // paints, which makes this widget's own hit-test result
                // "true" no matter what `behavior` says — and a `true`
                // result stops the surrounding `Stack` from ever testing
                // the actual PDF viewer sitting behind it, killing pan
                // *and* pinch-zoom for any touch landing on a page.
                // `IgnorePointer` keeps the painter fully visible while
                // making it invisible to hit-testing, so the `Stack`
                // keeps looking and the viewer underneath gets the
                // touch. `Listener.behavior: translucent` still makes
                // sure *we* also see every pointer event regardless.
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) => _onPagePointerDown(pageId, e),
                onPointerMove: (e) => _onPagePointerMove(pageId, e),
                onPointerUp: _onPagePointerUp,
                onPointerCancel: _onPagePointerCancel,
                child: IgnorePointer(
                  // This is the ONLY part that needs to react to selection
                  // changes on this page, and it can do so on its own,
                  // without pdfrx ever needing to call `pageOverlaysBuilder`
                  // again — pdfrx only re-invokes this callback on its own
                  // triggers (scroll/zoom/page load), not on our
                  // `SelectionController`'s changes.
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => CustomPaint(
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
        if (isDark)
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Stack(
              children: [
                for (final pageId in _pdfPages.keys)
                  if (controller.layoutFor(pageId) case final layout?)
                    for (final block in index.blocksByPage[pageId] ?? const <ChapterBlock>[])
                      if (block.type == BlockType.figure)
                        _FigureOverlay(
                          key: ValueKey(block.blockId),
                          rect: toScreen(block.bbox, layout),
                          imageFuture: _figureCropImage(block, _pdfPages[pageId]!),
                        ),
              ],
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _ChromeBarSlide(
            visible: _chromeVisible,
            fromTop: true,
            child: _TopBar(title: widget.title, colors: colors, debugOverlay: debugOverlay),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => _ChromeBarSlide(
              visible: _chromeVisible && !controller.isActive,
              fromTop: false,
              child: _BottomBar(colors: colors),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final selection = controller.selection;
            if (selection == null) return const SizedBox.shrink();
            return SelectionActionBar(
              selection: selection,
              viewportSize: _viewportSize,
              colors: colors,
            );
          },
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final selection = controller.selection;
            if (selection == null) return const SizedBox.shrink();
            return Stack(
              children: [
                _SelectionHandle(
                  key: ValueKey('start-${selection.blockIds.first}'),
                  center: selection.firstBlockRect.bottomLeft,
                  colors: colors,
                ),
                _SelectionHandle(
                  key: ValueKey('end-${selection.blockIds.last}'),
                  center: selection.lastBlockRect.bottomRight,
                  colors: colors,
                  // Second handle per the design's `handle` spec: same
                  // animation, 40ms behind the first.
                  delay: const Duration(milliseconds: 40),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Shows/hides a chrome bar with the design's `bump` animation (a brief
/// opacity + slight rise/fall, ease-out) instead of an instant show/hide.
/// Always mounted, unlike the old `if (_chromeVisible) ...` conditional this
/// replaces, so the transition has something to animate between — an
/// `IgnorePointer` takes back the job that conditional used to do for free
/// (a hidden bar shouldn't still catch touches).
class _ChromeBarSlide extends StatelessWidget {
  const _ChromeBarSlide({required this.visible, required this.fromTop, required this.child});

  final bool visible;
  final bool fromTop;
  final Widget child;

  static const _duration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: _duration,
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : Offset(0, fromTop ? -0.3 : 0.3),
        child: AnimatedOpacity(
          duration: _duration,
          curve: Curves.easeOut,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
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
    return SafeArea(
      bottom: false,
      child: Container(
          height: AppControlHeight.primaryButton,
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
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: AppControlHeight.chromeBar,
        color: colors.chrome,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
        alignment: Alignment.centerLeft,
        child: Text('Select text to ask, summarise or simplify',
            style: AppText.bodyChrome(colors.ink2)),
      ),
    );
  }
}

/// A single selection handle: a 44x44 touch target (per the brief's minimum
/// hit-area rule) centered on [center], containing a 13px amber dot. Not yet
/// independently draggable to adjust an existing selection — see
/// `bbox_overlay.dart`'s doc comment — this is purely the visual affordance
/// for now, so it's wrapped in `IgnorePointer`.
///
/// Animates in per the design's `handle` spec (scale .4→1, opacity 0→1,
/// 180ms ease-out), optionally starting [delay] after this widget mounts —
/// used for the 40ms stagger between the selection's start and end handles.
/// A new [key] (this widget is keyed by its anchor block's id at the call
/// site) mounts a fresh instance, which is what makes the animation replay
/// when a selection's start/end block actually changes.
/// A figure's unfiltered, full-color crop, painted at [rect] (global,
/// on-screen coordinates) on top of the tone-filtered page underneath —
/// see `_toneFilter`'s doc comment and `_figureCropImage`. Purely visual;
/// doesn't participate in hit-testing, so it never competes with selection
/// or the viewer's own pan/zoom for touches.
class _FigureOverlay extends StatelessWidget {
  const _FigureOverlay({required super.key, required this.rect, required this.imageFuture});

  final Rect rect;
  final Future<ui.Image> imageFuture;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: FutureBuilder<ui.Image>(
          future: imageFuture,
          builder: (context, snapshot) {
            final image = snapshot.data;
            if (image == null) return const SizedBox.shrink();
            return RawImage(image: image, fit: BoxFit.fill);
          },
        ),
      ),
    );
  }
}

class _SelectionHandle extends StatefulWidget {
  const _SelectionHandle({
    required super.key,
    required this.center,
    required this.colors,
    this.delay = Duration.zero,
  });

  final Offset center;
  final AppColors colors;
  final Duration delay;

  static const _touchSize = 44.0;
  static const _dotSize = 13.0;

  @override
  State<_SelectionHandle> createState() => _SelectionHandleState();
}

class _SelectionHandleState extends State<_SelectionHandle> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.center.dx - _SelectionHandle._touchSize / 2,
      top: widget.center.dy - _SelectionHandle._touchSize / 2,
      width: _SelectionHandle._touchSize,
      height: _SelectionHandle._touchSize,
      child: IgnorePointer(
        child: Center(
          child: _visible
              ? TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.scale(scale: 0.4 + 0.6 * t, child: child),
                  ),
                  child: Container(
                    width: _SelectionHandle._dotSize,
                    height: _SelectionHandle._dotSize,
                    decoration: BoxDecoration(color: widget.colors.amber, shape: BoxShape.circle),
                  ),
                )
              : const SizedBox.shrink(),
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
