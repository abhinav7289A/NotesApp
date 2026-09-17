import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:marginalia/reader/coordinate_conversion.dart';

void main() {
  group('toScreen — rotation 0', () {
    test('maps a bbox directly onto the page rect', () {
      const pageRect = Rect.fromLTWH(100, 50, 400, 800);
      const bbox = [0.25, 0.1, 0.75, 0.4];

      final result = toScreen(bbox, const PageLayout(pageRect: pageRect));

      expect(result.left, closeTo(100 + 0.25 * 400, 1e-9));
      expect(result.top, closeTo(50 + 0.1 * 800, 1e-9));
      expect(result.right, closeTo(100 + 0.75 * 400, 1e-9));
      expect(result.bottom, closeTo(50 + 0.4 * 800, 1e-9));
    });
  });

  // Known corner mappings, derived by hand in coordinate_conversion.dart's
  // design notes. Uses a unit-square page rect at the origin so the
  // expected screen coordinates equal the expected normalized coordinates
  // directly, isolating the rotation math from translation/scaling.
  group('toScreen — known corner mappings per rotation', () {
    const unitPage = Rect.fromLTWH(0, 0, 1, 1);

    Rect pointRect(double u, double v, int rotation) => toScreen(
          [u, v, u, v],
          PageLayout(pageRect: unitPage, rotation: rotation),
        );

    void expectPoint(Rect r, double x, double y) {
      expect(r.left, closeTo(x, 1e-9));
      expect(r.top, closeTo(y, 1e-9));
    }

    test('rotation 90 (clockwise): TL->TR, TR->BR, BR->BL, BL->TL', () {
      expectPoint(pointRect(0, 0, 90), 1, 0); // top-left -> top-right
      expectPoint(pointRect(1, 0, 90), 1, 1); // top-right -> bottom-right
      expectPoint(pointRect(1, 1, 90), 0, 1); // bottom-right -> bottom-left
      expectPoint(pointRect(0, 1, 90), 0, 0); // bottom-left -> top-left
    });

    test('rotation 180: opposite corners', () {
      expectPoint(pointRect(0, 0, 180), 1, 1);
      expectPoint(pointRect(1, 0, 180), 0, 1);
      expectPoint(pointRect(1, 1, 180), 0, 0);
      expectPoint(pointRect(0, 1, 180), 1, 0);
    });

    test('rotation 270 (clockwise): TL->BL, TR->TL, BR->TR, BL->BR', () {
      expectPoint(pointRect(0, 0, 270), 0, 1);
      expectPoint(pointRect(1, 0, 270), 0, 0);
      expectPoint(pointRect(1, 1, 270), 1, 0);
      expectPoint(pointRect(0, 1, 270), 1, 1);
    });
  });

  group('toNormalized is the exact inverse of toScreen', () {
    const pageRect = Rect.fromLTWH(37, 12, 360, 640); // arbitrary, non-square, offset

    const points = [
      [0.0, 0.0],
      [1.0, 0.0],
      [1.0, 1.0],
      [0.0, 1.0],
      [0.12, 0.88],
      [0.5, 0.5],
    ];

    for (final rotation in [0, 90, 180, 270]) {
      test('round-trips every sample point at rotation $rotation', () {
        for (final p in points) {
          final layout = PageLayout(pageRect: pageRect, rotation: rotation);
          final screenRect = toScreen([p[0], p[1], p[0], p[1]], layout);
          final recovered = toNormalized(screenRect.topLeft, layout);

          expect(recovered[0], closeTo(p[0], 1e-9),
              reason: 'u mismatch for point $p at rotation $rotation');
          expect(recovered[1], closeTo(p[1], 1e-9),
              reason: 'v mismatch for point $p at rotation $rotation');
        }
      });
    }
  });

  group('device-pixel-ratio independence', () {
    test('operates purely in the logical pixels of pageRect, unaware of DPR', () {
      // Two page rects of different logical sizes (as if rendered at
      // different DPRs) must each map the same normalized bbox
      // proportionally within their own rect — the function must never
      // assume a fixed physical size.
      const bbox = [0.2, 0.3, 0.6, 0.7];
      const smallRect = Rect.fromLTWH(0, 0, 200, 400);
      const largeRect = Rect.fromLTWH(0, 0, 600, 1200); // 3x DPR-equivalent

      final small = toScreen(bbox, const PageLayout(pageRect: smallRect));
      final large = toScreen(bbox, const PageLayout(pageRect: largeRect));

      expect(large.left / largeRect.width, closeTo(small.left / smallRect.width, 1e-9));
      expect(large.top / largeRect.height, closeTo(small.top / smallRect.height, 1e-9));
    });
  });
}
