import 'dart:typed_data';

import '../models/canonical_chapter.dart';
import '../models/document.dart';

/// One method per endpoint documented in `P1-backend-CLAUDE.md`.
///
/// TODO(contract): the only implementation right now is
/// [FixtureDocumentApi]. Per `COLLABORATION.md` §3 ("nobody hand-writes API
/// models"), a real backend-talking implementation belongs behind a client
/// generated from `contracts/openapi.json` (via
/// `dart run build_runner build`) once Dev B publishes one — do not
/// hand-roll a `dio` client here that pretends to be that generated code.
abstract class DocumentApi {
  /// `GET /v1/documents` — for the library screen.
  Future<List<DocumentSummary>> listDocuments();

  /// `POST /v1/documents` — registers a new upload and returns a presigned
  /// PUT URL. [filename] is the name of the file the user picked.
  Future<CreateDocumentResult> createDocument(String filename);

  /// `POST /v1/documents/{id}/ingest` — enqueues the ingest job, returns a
  /// job id (not otherwise used by P1 — status is polled via
  /// [getDocumentStatus], not the job id).
  Future<String> startIngest(String documentId);

  /// `GET /v1/documents/{id}` — poll target for the upload/OCR flow.
  Future<DocumentSummary> getDocumentStatus(String documentId);

  /// `GET /v1/documents/{id}/chapter` — the canonical chapter JSON.
  Future<CanonicalChapter> getChapter(String documentId);

  /// The original PDF's bytes, for on-device Pdfium rendering via `pdfrx`.
  /// Per `P1-mobile-CLAUDE.md`'s "known traps": the app never renders PDFs
  /// server-side and never re-fetches page images to read — it keeps the
  /// bytes of whatever the user picked/uploaded, locally, for offline
  /// reading. There is deliberately no "download the original PDF" backend
  /// endpoint in `P1-backend-CLAUDE.md` for this reason.
  Future<Uint8List> getLocalPdfBytes(String documentId);
}
