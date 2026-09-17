import 'dart:ui' show Offset, Rect;

/// Where a single page is currently laid out on screen, in **logical**
/// pixels (never physical/device pixels — mixing the two is the #1 way to
/// break alignment on high-DPI phones, see `P1-mobile-CLAUDE.md`).
///
/// [pageRect] is the rect the page is actually drawn into right now — for a
/// page with [rotation] 90 or 270 its width/height are already swapped
/// relative to the page's raw `width_pt`/`height_pt`, because that swapped
/// rect is what the user sees and what this page's overlay must align to.
class PageLayout {
  const PageLayout({required this.pageRect, this.rotation = 0})
      : assert(
          rotation == 0 || rotation == 90 || rotation == 180 || rotation == 270,
          'rotation must be one of 0, 90, 180, 270',
        );

  final Rect pageRect;
  final int rotation;
}

/// Converts a canonical `bbox` (`[x0, y0, x1, y1]`, normalized 0..1,
/// top-left origin, relative to the **unrotated** page — see
/// `contracts/canonical_chapter.schema.json`) into an on-screen [Rect] in
/// logical pixels.
///
/// This function and [toNormalized] are the **only** place page rotation
/// and coordinate math happen in the reader. Every highlight rect, every
/// debug overlay box, every hit test must go through one of these two —
/// scattering this math across widgets is how alignment bugs become
/// unfixable (see the brief's "coordinate problem" section).
///
/// Deliberately stays entirely in "canonical normalized (top-left) <->
/// Flutter screen (top-left, logical px)" space. It never has to reason
/// about Pdfium's bottom-left-origin page coordinates for that reason — if
/// some other part of the app ever reads raw geometry from pdfrx's
/// lower-level PDF-space APIs, flip *that* at the boundary before it
/// reaches here, not inside this function.
Rect toScreen(List<double> bbox, PageLayout layout) {
  assert(bbox.length == 4, 'bbox must be [x0, y0, x1, y1]');

  final corner1 = _rotateNormalized(bbox[0], bbox[1], layout.rotation);
  final corner2 = _rotateNormalized(bbox[2], bbox[3], layout.rotation);

  final left = corner1.dx < corner2.dx ? corner1.dx : corner2.dx;
  final top = corner1.dy < corner2.dy ? corner1.dy : corner2.dy;
  final right = corner1.dx > corner2.dx ? corner1.dx : corner2.dx;
  final bottom = corner1.dy > corner2.dy ? corner1.dy : corner2.dy;

  final w = layout.pageRect.width;
  final h = layout.pageRect.height;
  return Rect.fromLTRB(
    layout.pageRect.left + left * w,
    layout.pageRect.top + top * h,
    layout.pageRect.left + right * w,
    layout.pageRect.top + bottom * h,
  );
}

/// Inverse of [toScreen] for a single point: maps a screen-space [Offset]
/// (logical px — e.g. straight from a drag or tap gesture) back to the
/// canonical, normalized, unrotated-page coordinate space used by every
/// `bbox`. Returns `[u, v]`. Used to drive hit-testing against block boxes,
/// which are stored in that same canonical space.
List<double> toNormalized(Offset screenPoint, PageLayout layout) {
  final w = layout.pageRect.width;
  final h = layout.pageRect.height;
  final u = w == 0 ? 0.0 : (screenPoint.dx - layout.pageRect.left) / w;
  final v = h == 0 ? 0.0 : (screenPoint.dy - layout.pageRect.top) / h;
  return _unrotateNormalized(u, v, layout.rotation);
}

/// Canonical (unrotated, top-left) normalized point -> display (rotated,
/// top-left) normalized point.
Offset _rotateNormalized(double u, double v, int rotation) {
  switch (rotation) {
    case 90:
      return Offset(1 - v, u);
    case 180:
      return Offset(1 - u, 1 - v);
    case 270:
      return Offset(v, 1 - u);
    case 0:
    default:
      return Offset(u, v);
  }
}

/// Display (rotated, top-left) normalized point -> canonical (unrotated,
/// top-left) normalized point. Exact inverse of [_rotateNormalized].
List<double> _unrotateNormalized(double u, double v, int rotation) {
  switch (rotation) {
    case 90:
      return [v, 1 - u];
    case 180:
      return [1 - u, 1 - v];
    case 270:
      return [1 - v, u];
    case 0:
    default:
      return [u, v];
  }
}
