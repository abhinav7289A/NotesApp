import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_cache.g.dart';

/// One cached canonical chapter per document, so a previously opened
/// chapter still renders in airplane mode (P1 acceptance check 10). The
/// original PDF bytes are cached alongside it on disk (see
/// [LocalCache.cachePdfBytes]) rather than in the database, since drift is
/// for structured data, not multi-megabyte blobs.
class CachedChapters extends Table {
  TextColumn get documentId => text()();
  TextColumn get chapterJson => text()();
  DateTimeColumn get cachedAt => dateTime()();
  /// Path to the locally cached copy of the original PDF, relative to the
  /// app's documents directory.
  TextColumn get pdfPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {documentId};
}

@DriftDatabase(tables: [CachedChapters])
class LocalCache extends _$LocalCache {
  LocalCache() : super(driftDatabase(name: 'marginalia_cache'));

  @override
  int get schemaVersion => 1;

  Future<void> putChapter(String documentId, String chapterJson) {
    return into(cachedChapters).insertOnConflictUpdate(
      CachedChaptersCompanion.insert(
        documentId: documentId,
        chapterJson: chapterJson,
        cachedAt: DateTime.now(),
      ),
    );
  }

  Future<String?> getChapterJson(String documentId) async {
    final row = await (select(cachedChapters)
          ..where((t) => t.documentId.equals(documentId)))
        .getSingleOrNull();
    return row?.chapterJson;
  }

  /// Writes [bytes] to the app's documents directory and records the path
  /// against [documentId], so the reader can open the PDF from disk without
  /// a network connection on a later visit.
  Future<String> cachePdfBytes(String documentId, Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pdf_cache', '$documentId.pdf');
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    await into(cachedChapters).insertOnConflictUpdate(
      CachedChaptersCompanion.insert(
        documentId: documentId,
        chapterJson: await getChapterJson(documentId) ?? '',
        cachedAt: DateTime.now(),
        pdfPath: Value(path),
      ),
    );
    return path;
  }

  Future<String?> getCachedPdfPath(String documentId) async {
    final row = await (select(cachedChapters)
          ..where((t) => t.documentId.equals(documentId)))
        .getSingleOrNull();
    final path = row?.pdfPath;
    if (path == null) return null;
    return File(path).existsSync() ? path : null;
  }
}
