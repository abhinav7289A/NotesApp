// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngestError _$IngestErrorFromJson(Map<String, dynamic> json) => _IngestError(
  code: $enumDecode(_$IngestErrorCodeEnumMap, json['code']),
  message: json['message'] as String,
);

Map<String, dynamic> _$IngestErrorToJson(_IngestError instance) =>
    <String, dynamic>{
      'code': _$IngestErrorCodeEnumMap[instance.code]!,
      'message': instance.message,
    };

const _$IngestErrorCodeEnumMap = {
  IngestErrorCode.scanTooPoor: 'SCAN_TOO_POOR',
  IngestErrorCode.encryptedPdf: 'ENCRYPTED_PDF',
  IngestErrorCode.tooManyPages: 'TOO_MANY_PAGES',
  IngestErrorCode.corruptFile: 'CORRUPT_FILE',
};

_DocumentSummary _$DocumentSummaryFromJson(Map<String, dynamic> json) =>
    _DocumentSummary(
      documentId: json['document_id'] as String,
      title: json['title'] as String,
      status: $enumDecode(_$DocumentStatusEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      pageCount: (json['page_count'] as num?)?.toInt(),
      error: json['error'] == null
          ? null
          : IngestError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DocumentSummaryToJson(_DocumentSummary instance) =>
    <String, dynamic>{
      'document_id': instance.documentId,
      'title': instance.title,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'page_count': instance.pageCount,
      'error': instance.error,
    };

const _$DocumentStatusEnumMap = {
  DocumentStatus.uploaded: 'uploaded',
  DocumentStatus.processing: 'processing',
  DocumentStatus.ready: 'ready',
  DocumentStatus.failed: 'failed',
};

_CreateDocumentResult _$CreateDocumentResultFromJson(
  Map<String, dynamic> json,
) => _CreateDocumentResult(
  documentId: json['document_id'] as String,
  uploadUrl: json['upload_url'] as String,
);

Map<String, dynamic> _$CreateDocumentResultToJson(
  _CreateDocumentResult instance,
) => <String, dynamic>{
  'document_id': instance.documentId,
  'upload_url': instance.uploadUrl,
};
