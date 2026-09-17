import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:marginalia/models/canonical_chapter.dart';
import 'package:marginalia/reader/coordinate_conversion.dart';
import 'package:marginalia/reader/selection_controller.dart';

CanonicalChapter _loadFixture(String name) {
  final raw = File('assets/fixtures/$name.json').readAsStringSync();
  return CanonicalChapter.fromJson(json.decode(raw) as Map<String, dynamic>);
}

void main() {
  group('SelectionController on the two-column fixture', () {
    late CanonicalChapter chapter;
    late SelectionController controller;

    setUp(() {
      chapter = _loadFixture('chapter_twocolumn');
      controller = SelectionController(chapter);
      // Two pages stacked vertically, as the reader lays them out.
      controller.registerPageLayout(
        'p00001',
        const PageLayout(pageRect: Rect.fromLTWH(0, 0, 400, 800)),
      );
      controller.registerPageLayout(
        'p00002',
        const PageLayout(pageRect: Rect.fromLTWH(0, 820, 400, 800)),
      );
    });

    test(
        'a drag covering both columns of page 1 returns blocks in canonical '
        'reading order, not JSON array order or raster (left-to-right) order',
        () {
      // Drag from the very top-left to the very bottom-right of page 1,
      // covering both columns entirely.
      controller.startDrag('p00001', const Offset(0, 0));
      controller.updateDrag('p00001', const Offset(400, 800));

      final selection = controller.selection;
      expect(selection, isNotNull);

      // Expected: heading, then the whole left column top-to-bottom, then
      // the whole right column top-to-bottom — matching each block's
      // `order` field. The fixture's JSON array is deliberately NOT in this
      // order (it interleaves the columns to simulate raster extraction
      // order), so this proves the controller sorts by `order`.
      expect(selection!.blockIds, [
        'p00001_b001', // heading, order 0
        'p00001_b003', // left column, order 1
        'p00001_b005', // left column, order 2
        'p00001_b006', // left column, order 3
        'p00001_b002', // right column, order 4
        'p00001_b004', // right column, order 5
        'p00001_b007', // right column, order 6
      ]);
      expect(selection.pageIds, ['p00001']);
    });

    test('a drag confined to the left column only selects left-column blocks', () {
      controller.startDrag('p00001', const Offset(0, 0));
      // Left column spans x=0.08..0.47 (32..188 of 400); right column starts
      // at x=0.53 (212). Stop well inside the gap so the right column's
      // bbox (which starts at 212) is not touched.
      controller.updateDrag('p00001', const Offset(200, 800));

      final selection = controller.selection!;
      expect(selection.blockIds, ['p00001_b001', 'p00001_b003', 'p00001_b005', 'p00001_b006']);
    });

    test('a drag spanning from page 1 into page 2 collects blocks from both, '
        'page 1 first', () {
      // y=600 falls inside page 1's last two blocks (bbox y-ranges 448-640
      // and 480-680 of an 800-tall page); y=100 on page 2 falls inside its
      // heading and first paragraph — so the drag genuinely touches content
      // on both pages, not just empty margin.
      controller.startDrag('p00001', const Offset(0, 600));
      controller.updateDrag('p00002', const Offset(400, 150));

      final selection = controller.selection!;
      expect(selection.pageIds, containsAll(['p00001', 'p00002']));
      // Every returned block id must belong to one of the two known pages,
      // and page-1 blocks must all precede page-2 blocks (global `order`
      // is monotonic across the chapter).
      final page1Count = selection.blockIds.where((id) => id.startsWith('p00001_')).length;
      for (var i = 0; i < page1Count; i++) {
        expect(selection.blockIds[i], startsWith('p00001_'));
      }
      for (var i = page1Count; i < selection.blockIds.length; i++) {
        expect(selection.blockIds[i], startsWith('p00002_'));
      }
    });

    test('clear() drops the selection', () {
      controller.startDrag('p00001', const Offset(0, 0));
      controller.updateDrag('p00001', const Offset(400, 800));
      expect(controller.isActive, isTrue);

      controller.clear();
      expect(controller.isActive, isFalse);
      expect(controller.selection, isNull);
    });
  });
}
