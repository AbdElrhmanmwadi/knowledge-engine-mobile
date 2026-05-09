import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';

class AnswerDisplayWidget extends ConsumerWidget {
  const AnswerDisplayWidget({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));
    final response = state.answerResponse;

    if (response == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      title: 'AI Answer',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            response.answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (response.retrievedChunks != null)
              _InfoPill(
                label: 'Retrieved chunks',
                value: response.retrievedChunks.toString(),
              ),
            _InfoPill(
              label: 'Signal',
              value: response.signal,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _copyText(
                context,
                text: response.answer,
                label: 'Answer copied to clipboard.',
              ),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy answer'),
            ),
            if (state.hasDebugData)
              TextButton.icon(
                onPressed: ref
                    .read(ragNotifierProvider(projectId).notifier)
                    .toggleDebugVisibility,
                icon: Icon(
                  state.isDebugVisible
                      ? Icons.visibility_off_outlined
                      : Icons.bug_report_outlined,
                ),
                label: Text(
                  state.isDebugVisible ? 'Hide debug' : 'Show debug',
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _copyText(
    BuildContext context, {
    required String text,
    required String label,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
