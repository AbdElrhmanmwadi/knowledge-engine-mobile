import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/translation_provider.dart';

class TranslationStatusCard extends ConsumerWidget {
  const TranslationStatusCard({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final created = state.createdJobResponse;
    final job = state.jobStatusResponse?.job;

    if (!state.hasVisibleStatusCard) {
      return const SizedBox.shrink();
    }

    final currentStatus = job?.status ?? created?.status ?? JobStatus.pending;
    final badgeColor = _statusColor(currentStatus);
    final jobId = job?.jobId ?? created?.jobId ?? '-';
    final resultFileId = job?.resultFileId;
    final errorMessage = job?.errorMessage;
    final progress = job?.progressPercentage;
    final createdAt = created?.createdAt;

    return AppCard(
      title: 'Job Status',
      margin: EdgeInsets.zero,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job ID',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    jobId,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(
              status: currentStatus,
              label: _labelize(currentStatus),
              backgroundColor: badgeColor,
              icon: _statusIcon(currentStatus),
            ),
          ],
        ),
        if (created != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoPill(
                label: 'Signal',
                value: created.signal,
              ),
              _InfoPill(
                label: 'Languages',
                value:
                    '${LanguageCodes.getLanguageName(created.sourceLang)} -> ${LanguageCodes.getLanguageName(created.targetLang)}',
              ),
              _InfoPill(
                label: 'Asset ID',
                value: created.assetId,
              ),
            ],
          ),
        ],
        if (createdAt != null) ...[
          const SizedBox(height: 12),
          Text(
            'Created: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (progress != null) ...[
          const SizedBox(height: 14),
          Text(
            'Progress: $progress%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ((progress.clamp(0, 100)) / 100).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: badgeColor.withOpacity(0.16),
            color: badgeColor,
          ),
        ],
        if (resultFileId != null && resultFileId.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result file ID',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      resultFileId,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _copyText(
                  context,
                  resultFileId,
                  'Result file ID copied.',
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy'),
              ),
            ],
          ),
        ],
        if (errorMessage != null && errorMessage.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
            ),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.errorColor,
                  ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          state.lastRefreshTime == null
              ? 'Status has not been refreshed from the backend yet.'
              : 'Last refreshed: ${DateFormat('HH:mm:ss').format(state.lastRefreshTime!.toLocal())}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _copyText(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case JobStatus.completed:
        return AppTheme.successColor;
      case JobStatus.failed:
        return AppTheme.errorColor;
      case JobStatus.pending:
      case JobStatus.processing:
        return AppTheme.warningColor;
      default:
        return AppTheme.infoColor;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case JobStatus.completed:
        return Icons.check_circle_outline;
      case JobStatus.failed:
        return Icons.error_outline;
      case JobStatus.pending:
        return Icons.hourglass_empty;
      case JobStatus.processing:
        return Icons.sync;
      default:
        return Icons.info_outline;
    }
  }

  static String _labelize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
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
        color: AppTheme.tertiaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.tertiaryColor.withOpacity(0.18)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }
}
