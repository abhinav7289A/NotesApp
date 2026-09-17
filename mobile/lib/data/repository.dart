import 'dart:convert';
import 'dart:io';

import '../models/canonical_chapter.dart';
import '../models/document.dart';
import 'document_api.dart';
import 'local_cache.dart';

/// Cache-first access to chapters and their original PDF bytes.
///
/// A chapter already in [LocalCache] is served from there without touching
/// [DocumentApi] at all — this is what makes airplane-mode reading of a
/// previously opened chapter work (P1 acceptance check 10). New chapters
/// are fetched then written through to the cache.
class ChapterRepository {
  ChapterRepository(this._api, this._cache);

  final DocumentApi _api;
  final LocalCache _cache;

  Future<List<DocumentSummary>> listDocuments() => _api.listDocuments();

  Future<DocumentSummary> getStatus(String documentId) =>
      _api.getDocumentStatus(documentId);

  Future<CreateDocumentResult> createDocument(String filename) =>
      _api.createDocument(filename);

  Future<String> startIngest(String documentId) => _api.startIngest(documentId);

  Future<CanonicalChapter> getChapter(
    String documentId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedJson = await _cache.getChapterJson(documentId);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          return CanonicalChapter.fromJson(
              json.decode(cachedJson) as Map<String, dynamic>);
        } catch (_) {
          // Corrupt cache entry — fall through and refetch.
        }
      }
    }

    final chapter = await _api.getChapter(documentId);
    await _cache.putChapter(documentId, json.encode(chapter.toJson()));
    return chapter;
  }

  /// A local [File] pointing at the chapter's original PDF, suitable for
  /// `pdfrx` to open directly. Downloads once, then always serves from
  /// disk — see `document_api.dart` for why there is no server-rendering
  /// fallback.
  Future<File> getLocalPdfFile(String documentId) async {
    final cachedPath = await _cache.getCachedPdfPath(documentId);
    if (cachedPath != null) return File(cachedPath);

    final bytes = await _api.getLocalPdfBytes(documentId);
    final path = await _cache.cachePdfBytes(documentId, bytes);
    return File(path);
  }
}
