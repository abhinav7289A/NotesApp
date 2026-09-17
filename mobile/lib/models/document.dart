import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Mirrors the `status` values from `GET /v1/documents/{id}` in
/// `P1-backend-CLAUDE.md`.
enum DocumentStatus { uploaded, processing, ready, failed }

/// Machine-readable failure codes from the ingest pipeline. Each one maps to
/// a different screen per the brief — never just show the human message.
enum IngestErrorCode {
  @JsonValue('SCAN_TOO_POOR')
  scanTooPoor,
  @JsonValue('ENCRYPTED_PDF')
  encryptedPdf,
  @JsonValue('TOO_MANY_PAGES')
  tooManyPages,
  @JsonValue('CORRUPT_FILE')
  corruptFile,
}

@freezed
abstract class IngestError with _$IngestError {
  const factory IngestError({
    required IngestErrorCode code,
    required String message,
  }) = _IngestError;

  factory IngestError.fromJson(Map<String, dynamic> json) =>
      _$IngestErrorFromJson(json);
}

/// One row in the library list (`GET /v1/documents`) and the shape polled
/// from `GET /v1/documents/{id}`.
@freezed
abstract class DocumentSummary with _$DocumentSummary {
  const factory DocumentSummary({
    @JsonKey(name: 'document_id') required String documentId,
    required String title,
    required DocumentStatus status,
    @Default(0) int progress,
    @JsonKey(name: 'page_count') int? pageCount,
    IngestError? error,
  }) = _DocumentSummary;

  factory DocumentSummary.fromJson(Map<String, dynamic> json) =>
      _$DocumentSummaryFromJson(json);
}

/// Response of `POST /v1/documents`.
@freezed
abstract class CreateDocumentResult with _$CreateDocumentResult {
  const factory CreateDocumentResult({
    @JsonKey(name: 'document_id') required String documentId,
    @JsonKey(name: 'upload_url') required String uploadUrl,
  }) = _CreateDocumentResult;

  factory CreateDocumentResult.fromJson(Map<String, dynamic> json) =>
      _$CreateDocumentResultFromJson(json);
}
