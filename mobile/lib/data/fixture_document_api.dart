import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../models/canonical_chapter.dart';
import '../models/document.dart';
import 'document_api.dart';

class _FixtureDoc {
  const _FixtureDoc({
    required this.documentId,
    required this.title,
    required this.fixtureAsset,
    required this.pdfAsset,
    required this.pageCount,
  });

  final String documentId;
  final String title;
  final String fixtureAsset;
  final String pdfAsset;
  final int pageCount;
}

/// Default [DocumentApi] for P1: serves the three committed fixtures from
/// `contracts/fixtures/` (bundled into the app under `assets/fixtures/`)
/// instead of making real HTTP calls, per `P1-mobile-CLAUDE.md`'s "work
/// against fixtures first" — mobile dev never blocks on the backend.
///
/// Two fixtures ("Ray Optics", "Cell Structure") are always in the library,
/// already `ready`, so the reader/selection work has something to open
/// immediately. The third ("The Mughal Empire") is only added to the
/// library after [createDocument] is called, and simulates the
/// uploading -> processing -> ready progression against a wall clock so the
/// upload screen's states have something real to poll.
class FixtureDocumentApi implements DocumentApi {
  final List<String> _uploadedIds = [];
  final Map<String, DateTime> _uploadStartedAt = {};
  final Set<String> _simulateFailure = {};

  static const _seedDocs = [
    _FixtureDoc(
      documentId: 'doc-clean',
      title: 'Physics XII, Chapter 9: Ray Optics',
      fixtureAsset: 'assets/fixtures/chapter_clean.json',
      pdfAsset: 'assets/fixtures/chapter_clean.pdf',
      pageCount: 3,
    ),
    _FixtureDoc(
      documentId: 'doc-twocolumn',
      title: 'Biology XI, Chapter 5: Cell Structure and Function',
      fixtureAsset: 'assets/fixtures/chapter_twocolumn.json',
      pdfAsset: 'assets/fixtures/chapter_twocolumn.pdf',
      pageCount: 2,
    ),
  ];

  static const _uploadableDoc = _FixtureDoc(
    documentId: 'doc-scanned',
    title: 'History VIII, Chapter 4: The Mughal Empire',
    fixtureAsset: 'assets/fixtures/chapter_scanned.json',
    pdfAsset: 'assets/fixtures/chapter_scanned.pdf',
    pageCount: 2,
  );

  static const Duration _simulatedProcessingTime = Duration(seconds: 3);

  _FixtureDoc _docById(String documentId) => [_uploadableDoc, ..._seedDocs]
      .firstWhere((d) => d.documentId == documentId);

  @override
  Future<List<DocumentSummary>> listDocuments() async {
    final ready = _seedDocs.map((d) => DocumentSummary(
          documentId: d.documentId,
          title: d.title,
          status: DocumentStatus.ready,
          progress: 100,
          pageCount: d.pageCount,
        ));
    final uploading =
        await Future.wait(_uploadedIds.map(getDocumentStatus));
    return [...uploading, ...ready];
  }

  /// Fixture-only affordance: pass `filename: 'trigger_error.pdf'` to make
  /// the simulated pipeline fail with [IngestErrorCode.scanTooPoor] instead
  /// of completing, so the upload screen's error state is reachable during
  /// dev without a real bad scan. Not part of the real contract.
  @override
  Future<CreateDocumentResult> createDocument(String filename) async {
    _uploadStartedAt[_uploadableDoc.documentId] = DateTime.now();
    if (!_uploadedIds.contains(_uploadableDoc.documentId)) {
      _uploadedIds.add(_uploadableDoc.documentId);
    }
    if (filename == 'trigger_error.pdf') {
      _simulateFailure.add(_uploadableDoc.documentId);
    } else {
      _simulateFailure.remove(_uploadableDoc.documentId);
    }
    return CreateDocumentResult(
      documentId: _uploadableDoc.documentId,
      uploadUrl: 'fixture://upload/${_uploadableDoc.documentId}',
    );
  }

  @override
  Future<String> startIngest(String documentId) async => 'job-$documentId';

  @override
  Future<DocumentSummary> getDocumentStatus(String documentId) async {
    final doc = _docById(documentId);
    final startedAt = _uploadStartedAt[documentId];
    if (startedAt == null) {
      // A seed document, always ready.
      return DocumentSummary(
        documentId: doc.documentId,
        title: doc.title,
        status: DocumentStatus.ready,
        progress: 100,
        pageCount: doc.pageCount,
      );
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= _simulatedProcessingTime) {
      if (_simulateFailure.contains(documentId)) {
        return DocumentSummary(
          documentId: doc.documentId,
          title: doc.title,
          status: DocumentStatus.failed,
          progress: 62,
          pageCount: doc.pageCount,
          error: const IngestError(
            code: IngestErrorCode.scanTooPoor,
            message:
                'Pages 1 to 2 came out too dark to read. Retake those pages '
                'with the book flat and the light behind you.',
          ),
        );
      }
      return DocumentSummary(
        documentId: doc.documentId,
        title: doc.title,
        status: DocumentStatus.ready,
        progress: 100,
        pageCount: doc.pageCount,
      );
    }

    final progress =
        (elapsed.inMilliseconds / _simulatedProcessingTime.inMilliseconds * 100)
            .clamp(0, 99)
            .round();
    return DocumentSummary(
      documentId: doc.documentId,
      title: doc.title,
      status: DocumentStatus.processing,
      progress: progress,
      pageCount: doc.pageCount,
    );
  }

  @override
  Future<CanonicalChapter> getChapter(String documentId) async {
    final doc = _docById(documentId);
    final raw = await rootBundle.loadString(doc.fixtureAsset);
    return CanonicalChapter.fromJson(
        json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Future<Uint8List> getLocalPdfBytes(String documentId) async {
    final doc = _docById(documentId);
    final data = await rootBundle.load(doc.pdfAsset);
    return data.buffer.asUint8List();
  }
}
