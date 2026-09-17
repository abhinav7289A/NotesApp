import 'dart:io';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/canonical_chapter.dart';
import '../models/document.dart';
import 'document_api.dart';
import 'fixture_document_api.dart';
import 'local_cache.dart';
import 'repository.dart';

final documentApiProvider = Provider<DocumentApi>((ref) {
  return FixtureDocumentApi();
});

final localCacheProvider = Provider<LocalCache>((ref) {
  final cache = LocalCache();
  ref.onDispose(cache.close);
  return cache;
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository(
    ref.watch(documentApiProvider),
    ref.watch(localCacheProvider),
  );
});

final documentsListProvider =
    FutureProvider.autoDispose<List<DocumentSummary>>((ref) {
  return ref.watch(chapterRepositoryProvider).listDocuments();
});

/// Polls `getStatus` until the document reaches a terminal state
/// (`ready`/`failed`), driving the upload screen's progress UI.
final documentStatusProvider =
    StreamProvider.autoDispose.family<DocumentSummary, String>(
  (ref, documentId) async* {
    final repo = ref.watch(chapterRepositoryProvider);
    while (true) {
      final status = await repo.getStatus(documentId);
      yield status;
      if (status.status == DocumentStatus.ready ||
          status.status == DocumentStatus.failed) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  },
);

final chapterProvider =
    FutureProvider.autoDispose.family<CanonicalChapter, String>(
  (ref, documentId) {
    return ref.watch(chapterRepositoryProvider).getChapter(documentId);
  },
);

/// A [ChapterIndex] built once per document and cached for as long as
/// something's watching it — see `ChapterIndex`'s doc comment for why this
/// exists (avoiding a per-frame sort+rebuild while dragging to select).
final chapterIndexProvider =
    FutureProvider.autoDispose.family<ChapterIndex, String>(
  (ref, documentId) async {
    final chapter = await ref.watch(chapterProvider(documentId).future);
    return ChapterIndex(chapter);
  },
);

final localPdfFileProvider = FutureProvider.autoDispose.family<File, String>(
  (ref, documentId) {
    return ref.watch(chapterRepositoryProvider).getLocalPdfFile(documentId);
  },
);

/// Persisted in-memory for now; P1 has no settings screen. Defaults to the
/// system setting.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Debug-only toggle that strokes every block bbox in amber over the page —
/// see `P1-mobile-CLAUDE.md`: "verify alignment visually before building
/// selection." Off by default so the shipped reading UI stays clean.
final debugBboxOverlayProvider = StateProvider<bool>((ref) => false);
