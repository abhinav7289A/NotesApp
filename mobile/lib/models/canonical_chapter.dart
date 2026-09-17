import 'package:freezed_annotation/freezed_annotation.dart';

part 'canonical_chapter.freezed.dart';
part 'canonical_chapter.g.dart';

/// Block classification. Mirrors the `type` enum in
/// `contracts/canonical_chapter.schema.json` exactly — do not add values here
/// without updating the schema and getting Dev B's sign-off first.
enum BlockType {
  heading,
  paragraph,
  @JsonValue('list_item')
  listItem,
  figure,
  caption,
  table,
  formula,
  header,
  footer,
  @JsonValue('page_number')
  pageNumber,
}

/// One page of a chapter. `pageId` follows `^p[0-9]{5}$` and is stable
/// forever — every block anchors to it.
@freezed
abstract class ChapterPage with _$ChapterPage {
  const factory ChapterPage({
    @JsonKey(name: 'page_id') required String pageId,
    required int index,
    @JsonKey(name: 'width_pt') required double widthPt,
    @JsonKey(name: 'height_pt') required double heightPt,
    @Default(0) int rotation,
    @JsonKey(name: 'image_key') String? imageKey,
    @JsonKey(name: 'has_text_layer') bool? hasTextLayer,
  }) = _ChapterPage;

  factory ChapterPage.fromJson(Map<String, dynamic> json) =>
      _$ChapterPageFromJson(json);
}

/// One block on a page. `blockId` follows `^p[0-9]{5}_b[0-9]{3}$` and is
/// stable forever — every annotation, AI answer and cache entry anchors to
/// this id. `bbox` is `[x0, y0, x1, y1]` normalized 0..1, origin top-left,
/// relative to the *unrotated* page. Never treat it as absolute points.
@freezed
abstract class ChapterBlock with _$ChapterBlock {
  const factory ChapterBlock({
    @JsonKey(name: 'block_id') required String blockId,
    @JsonKey(name: 'page_id') required String pageId,
    required BlockType type,
    String? text,
    required List<double> bbox,
    required int order,
    int? level,
    double? confidence,
    @JsonKey(name: 'image_key') String? imageKey,
  }) = _ChapterBlock;

  factory ChapterBlock.fromJson(Map<String, dynamic> json) =>
      _$ChapterBlockFromJson(json);
}

/// The canonical chapter document — the shared contract with the backend.
/// `schemaVersion` must equal 1; reject anything else rather than guessing
/// at a newer shape.
@freezed
abstract class CanonicalChapter with _$CanonicalChapter {
  const factory CanonicalChapter({
    @JsonKey(name: 'schema_version') required int schemaVersion,
    @JsonKey(name: 'chapter_id') required String chapterId,
    @JsonKey(name: 'content_hash') required String contentHash,
    required String title,
    @JsonKey(name: 'source_filename') String? sourceFilename,
    required String language,
    @JsonKey(name: 'page_count') required int pageCount,
    @JsonKey(name: 'ocr_engine') String? ocrEngine,
    @JsonKey(name: 'created_at') String? createdAt,
    required List<ChapterPage> pages,
    required List<ChapterBlock> blocks,
  }) = _CanonicalChapter;

  factory CanonicalChapter.fromJson(Map<String, dynamic> json) =>
      _$CanonicalChapterFromJson(json);
}

extension CanonicalChapterLookup on CanonicalChapter {
  Map<String, ChapterPage> get pagesById => {
        for (final p in pages) p.pageId: p,
      };
}

/// Precomputed lookups over a [CanonicalChapter]'s blocks, built once and
/// reused for the chapter's lifetime.
///
/// This replaces two getters that used to live directly on
/// [CanonicalChapterLookup] (`blocksInReadingOrder`, `blocksByPage`), which
/// recomputed a full sort and rebuilt a fresh `Map` on *every* access. Those
/// getters were called once per visible page on every `PdfViewer` rebuild
/// and once per registered page on every selection-drag update — i.e. on
/// every pointer-move frame while dragging — which was the dominant cause of
/// dragging-to-select feeling laggy. Chapters are immutable once loaded
/// (keyed by `content_hash`), so indexing once here and reusing the result
/// is always safe.
class ChapterIndex {
  factory ChapterIndex(CanonicalChapter chapter) {
    final sorted = [...chapter.blocks]..sort((a, b) => a.order.compareTo(b.order));
    final byPage = <String, List<ChapterBlock>>{};
    for (final b in sorted) {
      byPage.putIfAbsent(b.pageId, () => []).add(b);
    }
    return ChapterIndex._(chapter, sorted, byPage);
  }

  const ChapterIndex._(this.chapter, this.blocksInReadingOrder, this.blocksByPage);

  final CanonicalChapter chapter;

  /// Blocks in true reading order (the `order` field), never JSON array
  /// order and never visual left-to-right — see the two-column fixture.
  final List<ChapterBlock> blocksInReadingOrder;

  final Map<String, List<ChapterBlock>> blocksByPage;
}
