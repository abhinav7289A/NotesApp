import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../models/document.dart';
import '../reader/reader_screen.dart';
import '../theme/tokens.dart';
import '../upload/upload_screen.dart';

/// Library / home screen. P1 scope: list documents from the API, open one.
/// The design handoff's "Continue card" and "Made from your documents"
/// (revision notes / quiz shortcuts) depend on read-progress and
/// AI-generated artifacts that don't exist until later phases — omitted
/// here rather than built against fake data.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final documentsAsync = ref.watch(documentsListProvider);

    return Scaffold(
      backgroundColor: colors.chrome,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Your library', style: AppText.screenTitle(colors.ink)),
              const SizedBox(height: AppSpacing.sm),
              Text('Free plan, 0 chats used this month',
                  style: AppText.bodyChrome(colors.ink2)),
              const SizedBox(height: AppSpacing.xl4),
              Expanded(
                child: documentsAsync.when(
                  loading: () => Center(child: CircularProgressIndicator(color: colors.amber)),
                  error: (e, _) => Center(
                    child: Text('Could not load your library: $e',
                        style: AppText.bodyChrome(colors.ink2)),
                  ),
                  data: (docs) => docs.isEmpty
                      ? _EmptyLibrary(colors: colors)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All documents', style: AppText.sectionLabel(colors.ink)),
                            const SizedBox(height: AppSpacing.lg),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: colors.hairline),
                                  borderRadius: BorderRadius.circular(AppRadii.primaryButton),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListView.separated(
                                  itemCount: docs.length,
                                  separatorBuilder: (_, _) => Divider(height: 1, color: colors.hairline),
                                  itemBuilder: (context, i) => _DocumentRow(doc: docs[i], colors: colors),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl3),
              SizedBox(
                width: double.infinity,
                height: AppControlHeight.primaryButton,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.ink,
                    foregroundColor: colors.page,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.primaryButton),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UploadScreen()),
                  ),
                  child: Text('Add a document', style: AppText.primaryButtonLabel(colors.page)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl3),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentRow extends ConsumerWidget {
  const _DocumentRow({required this.doc, required this.colors});
  final DocumentSummary doc;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = switch (doc.status) {
      DocumentStatus.ready =>
        doc.pageCount != null ? '${doc.pageCount} pages' : 'Ready',
      DocumentStatus.processing => 'Reading, ${doc.progress}%',
      DocumentStatus.uploaded => 'Waiting to process',
      DocumentStatus.failed => doc.error?.message ?? 'Could not process this document',
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 34,
        height: 44,
        decoration: BoxDecoration(
          color: colors.elev,
          border: Border.all(color: colors.hairline),
        ),
      ),
      title: Text(doc.title, style: AppText.documentBody(colors.ink).copyWith(fontSize: 15)),
      subtitle: Text(
        subtitle,
        style: AppText.bodyChrome(
          doc.status == DocumentStatus.failed ? colors.rose : colors.ink2,
        ),
      ),
      onTap: doc.status == DocumentStatus.ready
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReaderScreen(documentId: doc.documentId, title: doc.title),
                ),
              )
          : null,
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nothing here yet', style: AppText.screenTitle(colors.ink)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Add one chapter and you can select any paragraph to ask about it.',
              style: AppText.documentBody(colors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A photograph of two pages is enough to start.',
              style: AppText.documentBody(colors.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
