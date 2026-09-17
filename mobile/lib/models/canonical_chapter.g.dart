// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canonical_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChapterPage _$ChapterPageFromJson(Map<String, dynamic> json) => _ChapterPage(
  pageId: json['page_id'] as String,
  index: (json['index'] as num).toInt(),
  widthPt: (json['width_pt'] as num).toDouble(),
  heightPt: (json['height_pt'] as num).toDouble(),
  rotation: (json['rotation'] as num?)?.toInt() ?? 0,
  imageKey: json['image_key'] as String?,
  hasTextLayer: json['has_text_layer'] as bool?,
);

Map<String, dynamic> _$ChapterPageToJson(_ChapterPage instance) =>
    <String, dynamic>{
      'page_id': instance.pageId,
      'index': instance.index,
      'width_pt': instance.widthPt,
      'height_pt': instance.heightPt,
      'rotation': instance.rotation,
      'image_key': instance.imageKey,
      'has_text_layer': instance.hasTextLayer,
    };

_ChapterBlock _$ChapterBlockFromJson(Map<String, dynamic> json) =>
    _ChapterBlock(
      blockId: json['block_id'] as String,
      pageId: json['page_id'] as String,
      type: $enumDecode(_$BlockTypeEnumMap, json['type']),
      text: json['text'] as String?,
      bbox: (json['bbox'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      order: (json['order'] as num).toInt(),
      level: (json['level'] as num?)?.toInt(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      imageKey: json['image_key'] as String?,
    );

Map<String, dynamic> _$ChapterBlockToJson(_ChapterBlock instance) =>
    <String, dynamic>{
      'block_id': instance.blockId,
      'page_id': instance.pageId,
      'type': _$BlockTypeEnumMap[instance.type]!,
      'text': instance.text,
      'bbox': instance.bbox,
      'order': instance.order,
      'level': instance.level,
      'confidence': instance.confidence,
      'image_key': instance.imageKey,
    };

const _$BlockTypeEnumMap = {
  BlockType.heading: 'heading',
  BlockType.paragraph: 'paragraph',
  BlockType.listItem: 'list_item',
  BlockType.figure: 'figure',
  BlockType.caption: 'caption',
  BlockType.table: 'table',
  BlockType.formula: 'formula',
  BlockType.header: 'header',
  BlockType.footer: 'footer',
  BlockType.pageNumber: 'page_number',
};

_CanonicalChapter _$CanonicalChapterFromJson(Map<String, dynamic> json) =>
    _CanonicalChapter(
      schemaVersion: (json['schema_version'] as num).toInt(),
      chapterId: json['chapter_id'] as String,
      contentHash: json['content_hash'] as String,
      title: json['title'] as String,
      sourceFilename: json['source_filename'] as String?,
      language: json['language'] as String,
      pageCount: (json['page_count'] as num).toInt(),
      ocrEngine: json['ocr_engine'] as String?,
      createdAt: json['created_at'] as String?,
      pages: (json['pages'] as List<dynamic>)
          .map((e) => ChapterPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => ChapterBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CanonicalChapterToJson(_CanonicalChapter instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'chapter_id': instance.chapterId,
      'content_hash': instance.contentHash,
      'title': instance.title,
      'source_filename': instance.sourceFilename,
      'language': instance.language,
      'page_count': instance.pageCount,
      'ocr_engine': instance.ocrEngine,
      'created_at': instance.createdAt,
      'pages': instance.pages,
      'blocks': instance.blocks,
    };
