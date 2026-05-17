import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:knowledge_engine_mobile/features/translation/presentation/pages/translate_page.dart';

import '../../../../core/config/constants.dart';
import '../providers/translation_provider.dart';

class TranslationStatusCard extends ConsumerWidget {
  const TranslationStatusCard({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier =
        ref.read(translationNotifierProvider(projectId).notifier);
    final created = state.createdJobResponse;
    final job = state.jobStatusResponse?.job;

    if (!state.hasVisibleStatusCard) return const SizedBox.shrink();

    final currentStatus =
        job?.status ?? created?.status ?? JobStatus.pending;
    final badgeColor = _statusColor(currentStatus);
    final jobId = job?.jobId ?? created?.jobId ?? '-';
    final resultFileId = job?.resultFileId;
    final resultAssetId = job?.resultAssetId;
    final errorMessage = job?.errorMessage;
    final progress = job?.progressPercentage;
    final createdAt = created?.createdAt;
    final sourceLang = job?.sourceLang ?? created?.sourceLang;
    final targetLang = job?.targetLang ?? created?.targetLang;
    final sourceAssetId = job?.assetId ?? created?.assetId;
    final isCompleted =
        currentStatus.toLowerCase() == JobStatus.completed;
    final isFailed = currentStatus.toLowerCase() == JobStatus.failed;

    return Container(
      decoration: BoxDecoration(
        color: TColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Icon(_statusIcon(currentStatus),
                    color: badgeColor, size: 16),
                const SizedBox(width: 7),
                Text(
                  'TRANSLATION REQUEST',
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                _StatusPill(
                    status: currentStatus, color: badgeColor),
              ],
            ),
          ),
          Divider(
              color: Colors.white.withOpacity(0.06), height: 20),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Job ID ────────────────────────────────────
                const Text(
                  'REQUEST ID',
                  style: TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  jobId,
                  style: const TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 14),

                // ── Info pills ────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (created != null)
                      _InfoPill(
                          label: 'Signal', value: created.signal as String),
                    if (sourceLang != null && targetLang != null)
                      _InfoPill(
                        label: 'Route',
                        value:
                            '${LanguageCodes.getLanguageName(sourceLang as String)} → ${LanguageCodes.getLanguageName(targetLang as String)}',
                      ),
                    if (sourceAssetId != null)
                      _InfoPill(
                          label: 'Asset', value: sourceAssetId as String),
                  ],
                ),

                // ── Created at ────────────────────────────────
                if (createdAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Created ${DateFormat('yyyy-MM-dd HH:mm:ss').format((createdAt as DateTime).toLocal())}',
                    style: const TextStyle(
                        color: TColors.textSecondary, fontSize: 11),
                  ),
                ],

                // ── Progress bar ──────────────────────────────
                if (progress != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: TColors.textSecondary
                              .withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: ((progress as int).clamp(0, 100) / 100)
                          .toDouble(),
                      minHeight: 6,
                      backgroundColor:
                          badgeColor.withOpacity(0.15),
                      color: badgeColor,
                    ),
                  ),
                ],

                // ── Result file ───────────────────────────────
                if (resultFileId != null &&
                    (resultFileId as String).trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ResultSection(
                    resultFileId: resultFileId,
                    resultAssetId: resultAssetId as String?,
                    isCompleted: isCompleted,
                    isDownloading: state.isDownloading,
                    downloadError: state.downloadError,
                    onDownload: () async {
                      final path =
                          await notifier.downloadResultFile();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(path != null
                              ? 'Saved to $path'
                              : state.downloadError ??
                                  'Download failed.'),
                        ),
                      );
                    },
                    onCopyFile: () => _copy(
                        context, resultFileId, 'Filename copied'),
                    onCopyAsset: resultAssetId != null &&
                            (resultAssetId as String).trim().isNotEmpty
                        ? () => _copy(context,
                            resultAssetId as String, 'Asset ID copied')
                        : null,
                  ),
                ],

                // ── Error banners ─────────────────────────────
                if (isFailed &&
                    (errorMessage == null ||
                        (errorMessage as String).trim().isEmpty)) ...[
                  const SizedBox(height: 14),
                  _InlineBanner(
                    color: TColors.error,
                    icon: Icons.error_outline_rounded,
                    message: 'Translation failed. Please try again.',
                  ),
                ],
                if (errorMessage != null &&
                    (errorMessage as String).trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _InlineBanner(
                    color: TColors.error,
                    icon: Icons.error_outline_rounded,
                    message: errorMessage as String,
                  ),
                ],
                if (state.downloadError != null &&
                    state.downloadError!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.downloadError!,
                    style: const TextStyle(
                        color: TColors.error, fontSize: 11),
                  ),
                ],

                // ── Last refreshed ────────────────────────────
                const SizedBox(height: 14),
                Text(
                  state.lastRefreshTime == null
                      ? 'Not yet refreshed from backend.'
                      : 'Last refreshed: ${DateFormat('HH:mm:ss').format((state.lastRefreshTime as DateTime).toLocal())}',
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(label)));
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case JobStatus.completed:
        return TColors.teal;
      case JobStatus.failed:
        return TColors.error;
      case JobStatus.pending:
      case JobStatus.processing:
        return TColors.amber;
      default:
        return TColors.accent;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case JobStatus.completed:
        return Icons.check_circle_outline_rounded;
      case JobStatus.failed:
        return Icons.error_outline_rounded;
      case JobStatus.pending:
        return Icons.hourglass_empty_rounded;
      case JobStatus.processing:
        return Icons.sync_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

// ── Result section ──────────────────────────────────────────────────────────
class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.resultFileId,
    required this.resultAssetId,
    required this.isCompleted,
    required this.isDownloading,
    required this.downloadError,
    required this.onDownload,
    required this.onCopyFile,
    required this.onCopyAsset,
  });

  final String resultFileId;
  final String? resultAssetId;
  final bool isCompleted;
  final bool isDownloading;
  final String? downloadError;
  final VoidCallback onDownload;
  final VoidCallback onCopyFile;
  final VoidCallback? onCopyAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.teal.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: TColors.teal, size: 15),
              const SizedBox(width: 6),
              const Text(
                'TRANSLATED FILE READY',
                style: TextStyle(
                  color: TColors.teal,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Result filename',
            style: TextStyle(
                color: TColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          SelectableText(
            resultFileId,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'Courier',
            ),
          ),
          if (resultAssetId != null &&
              resultAssetId!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Result asset ID',
              style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            SelectableText(
              resultAssetId!,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'Courier',
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isCompleted)
                FilledButton.icon(
                  onPressed: isDownloading ? null : onDownload,
                  style: FilledButton.styleFrom(
                    backgroundColor: TColors.teal,
                    foregroundColor: const Color(0xFF0D0F14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  icon: isDownloading
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0D0F14)),
                        )
                      : const Icon(Icons.download_rounded, size: 15),
                  label: Text(
                      isDownloading ? 'Downloading…' : 'Download'),
                ),
              _CopyButton(
                  label: 'Copy filename', onTap: onCopyFile),
              if (onCopyAsset != null)
                _CopyButton(
                    label: 'Copy asset ID',
                    onTap: onCopyAsset!),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 10),
            _InlineBanner(
              color: TColors.amber,
              icon: Icons.hourglass_top_rounded,
              message:
                  'Translation is being prepared. Download will appear once complete.',
            ),
          ],
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: TColors.textSecondary,
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      icon: const Icon(Icons.copy_outlined, size: 13),
      label: Text(label),
    );
  }
}

// ── Shared mini widgets ─────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty
        ? status
        : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: TColors.amber.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TColors.amber.withOpacity(0.2)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: TColors.amber,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.color,
    required this.icon,
    required this.message,
  });
  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: color, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}