import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../models/document.dart';
import '../reader/reader_screen.dart';
import '../theme/tokens.dart';

enum _Phase { pick, sending, processing, error, done }

/// The five-state upload flow from `P1-mobile-CLAUDE.md` / the design
/// handoff's screen C, driven against [FixtureDocumentApi]'s simulated
/// pipeline (see that file) rather than a real backend — there isn't one
/// yet. "Photograph pages" is left visible but disabled: camera capture
/// isn't called out in the P1 mobile scope bullet list and would need real
/// device camera + straightening work that belongs with the real ingest
/// pipeline, not stubbed against fixtures.
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  _Phase _phase = _Phase.pick;
  String? _documentId;

  Future<void> _pick({required bool simulateError}) async {
    final repo = ref.read(chapterRepositoryProvider);
    setState(() => _phase = _Phase.sending);

    final created = await repo.createDocument(
      simulateError ? 'trigger_error.pdf' : 'history-viii-ch4-scan.pdf',
    );
    _documentId = created.documentId;

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    await repo.startIngest(created.documentId);
    if (!mounted) return;
    setState(() => _phase = _Phase.processing);
  }

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;

    if (_documentId != null && _phase == _Phase.processing) {
      ref.listen(documentStatusProvider(_documentId!), (previous, next) {
        next.whenData((status) {
          if (status.status == DocumentStatus.ready) {
            setState(() => _phase = _Phase.done);
          } else if (status.status == DocumentStatus.failed) {
            setState(() => _phase = _Phase.error);
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: colors.chrome,
      appBar: AppBar(
        backgroundColor: colors.chrome,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.ink),
        title: Text('Add a document', style: AppText.navBarTitle(colors.ink)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    switch (_phase) {
      case _Phase.pick:
        return _PickBody(
          colors: colors,
          onPick: () => _pick(simulateError: false),
          onSimulateError: () => _pick(simulateError: true),
        );
      case _Phase.sending:
        return _SendingBody(colors: colors);
      case _Phase.processing:
        return _ProcessingBody(colors: colors, documentId: _documentId!);
      case _Phase.error:
        return _ErrorBody(
          colors: colors,
          documentId: _documentId!,
          onRetake: () => setState(() => _phase = _Phase.pick),
        );
      case _Phase.done:
        return _DoneBody(colors: colors, documentId: _documentId!);
    }
  }
}

class _PickBody extends StatelessWidget {
  const _PickBody({required this.colors, required this.onPick, required this.onSimulateError});
  final AppColors colors;
  final VoidCallback onPick;
  final VoidCallback onSimulateError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          decoration: BoxDecoration(
            color: colors.page,
            border: Border.all(color: colors.hairline),
          ),
          child: Text(
            'Pick a PDF, or photograph pages of a book. Photos are straightened '
            'and read before they reach the reader.',
            style: AppText.bodyChrome(colors.ink2),
          ),
        ),
        const SizedBox(height: AppSpacing.xl3),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.ink,
              foregroundColor: colors.page,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.primaryButton)),
            ),
            onPressed: onPick,
            child: Text('Choose a PDF', style: AppText.primaryButtonLabel(colors.page)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.ink2,
              side: BorderSide(color: colors.hairline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.primaryButton)),
            ),
            onPressed: null, // out of P1 scope — see file doc comment
            child: Text('Photograph pages', style: AppText.primaryButtonLabel(colors.ink2)),
          ),
        ),
        const SizedBox(height: AppSpacing.xl4),
        Text(
          'Your free plan includes one document a month. This is your first.',
          style: AppText.caption(colors.ink2),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSimulateError,
          child: Text(
            'Dev: simulate a failed scan',
            style: AppText.caption(colors.ink2),
          ),
        ),
      ],
    );
  }
}

class _SendingBody extends StatelessWidget {
  const _SendingBody({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Uploading over 4G', style: AppText.documentH2(colors.ink)),
        const SizedBox(height: AppSpacing.xl2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            minHeight: 3,
            backgroundColor: colors.hairline,
            color: colors.amber,
          ),
        ),
      ],
    );
  }
}

class _ProcessingBody extends ConsumerWidget {
  const _ProcessingBody({required this.colors, required this.documentId});
  final AppColors colors;
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(documentStatusProvider(documentId)).valueOrNull;
    final progress = (status?.progress ?? 0) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Reading the pages', style: AppText.documentH2(colors.ink)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Text, figures and equations are being recognised so you can select '
          'and ask about them.',
          style: AppText.bodyChrome(colors.ink2),
        ),
        const SizedBox(height: AppSpacing.xl2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: colors.hairline,
            color: colors.amber,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('${status?.progress ?? 0}%', style: AppText.provenance(colors.ink2)),
      ],
    );
  }
}

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({required this.colors, required this.documentId, required this.onRetake});
  final AppColors colors;
  final String documentId;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(documentStatusProvider(documentId)).valueOrNull;
    final error = status?.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          decoration: BoxDecoration(
            color: colors.page,
            border: Border.all(color: colors.rose, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                error?.message ?? 'Some pages came out too poor to read',
                style: AppText.documentH2(colors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl3),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.ink,
              foregroundColor: colors.page,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.primaryButton)),
            ),
            onPressed: onRetake,
            child: const Text('Retake pages'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.ink,
              side: BorderSide(color: colors.hairline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.primaryButton)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep as images'),
          ),
        ),
      ],
    );
  }
}

class _DoneBody extends ConsumerWidget {
  const _DoneBody({required this.colors, required this.documentId});
  final AppColors colors;
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(documentStatusProvider(documentId)).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${status?.title ?? 'Your document'} is ready', style: AppText.documentH2(colors.ink)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${status?.pageCount ?? '?'} pages read. Selecting a figure works the '
          'same as selecting text.',
          style: AppText.bodyChrome(colors.ink2),
        ),
        const SizedBox(height: AppSpacing.xl3),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.ink,
              foregroundColor: colors.page,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.primaryButton)),
            ),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ReaderScreen(
                  documentId: documentId,
                  title: status?.title ?? 'Document',
                ),
              ),
            ),
            child: const Text('Open at page 1'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Library', style: AppText.secondaryButtonLabel(colors.ink2)),
        ),
      ],
    );
  }
}
