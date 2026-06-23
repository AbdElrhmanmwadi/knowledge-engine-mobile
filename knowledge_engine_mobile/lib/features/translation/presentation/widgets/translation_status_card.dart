import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/constants.dart';
import '../providers/translation_provider.dart';
import '../../../../core/theme/app_radius.dart';

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
    final badgeColor = _statusColor(context, currentStatus);
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0.h),
            child: Row(
              children: [
                Icon(_statusIcon(currentStatus),
                    color: badgeColor, size: 16.r),
                SizedBox(width: 7.w),
                Text(
                  'TRANSLATION REQUEST',
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10.sp,
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
              color: Theme.of(context).dividerColor.withValues(alpha: 0.06), height: 20.h),

          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0.h, 18.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Job ID ────────────────────────────────────
                Text(
                  'REQUEST ID',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                SelectableText(
                  jobId,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    fontFamily: 'Courier',
                  ),
                ),
                SizedBox(height: 14.h),

                // ── Info pills ────────────────────────────────
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (created != null)
                      _InfoPill(
                          label: 'Signal', value: created.signal),
                    if (sourceLang != null && targetLang != null)
                      _InfoPill(
                        label: 'Route',
                        value:
                            '${LanguageCodes.getLanguageName(sourceLang)} → ${LanguageCodes.getLanguageName(targetLang)}',
                      ),
                    if (sourceAssetId != null)
                      _InfoPill(
                          label: 'Asset', value: sourceAssetId),
                  ],
                ),

                // ── Created at ────────────────────────────────
                if (createdAt != null) ...[
                  SizedBox(height: 10.h),
                    Text(
                      'Created ${DateFormat('yyyy-MM-dd HH:mm:ss').format((createdAt).toLocal())}',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
                    ),
                ],

                // ── Progress bar ──────────────────────────────
                if (progress != null) ...[
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99.r),
                    child: LinearProgressIndicator(
                      value: ((progress).clamp(0, 100) / 100)
                          .toDouble(),
                      minHeight: 6.h,
                      backgroundColor:
                          badgeColor.withValues(alpha: 0.15),
                      color: badgeColor,
                    ),
                  ),
                ],

                // ── Result file ───────────────────────────────
                if (resultFileId != null &&
                    (resultFileId).trim().isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _ResultSection(
                    resultFileId: resultFileId,
                    resultAssetId: resultAssetId,
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
                            (resultAssetId).trim().isNotEmpty
                        ? () => _copy(context,
                            resultAssetId, 'Asset ID copied')
                        : null,
                  ),
                ],

                // ── Error banners ─────────────────────────────
                if (isFailed &&
                    (errorMessage == null ||
                        (errorMessage).trim().isEmpty)) ...[
                  SizedBox(height: 14.h),
                    _InlineBanner(
                      color: Theme.of(context).colorScheme.error,
                      icon: Icons.error_outline_rounded,
                      message: 'Translation failed. Please try again.',
                    ),
                ],
                if (errorMessage != null &&
                    (errorMessage).trim().isNotEmpty) ...[
                  SizedBox(height: 14.h),
                    _InlineBanner(
                      color: Theme.of(context).colorScheme.error,
                      icon: Icons.error_outline_rounded,
                      message: errorMessage,
                    ),
                ],
                if (state.downloadError != null &&
                    state.downloadError!.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    state.downloadError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error, fontSize: 11.sp),
                  ),
                ],

                // ── Last refreshed ────────────────────────────
                SizedBox(height: 14.h),
                Text(
                  state.lastRefreshTime == null
                      ? 'Not yet refreshed from backend.'
                      : 'Last refreshed: ${DateFormat('HH:mm:ss').format((state.lastRefreshTime as DateTime).toLocal())}',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
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

  static Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case JobStatus.completed:
        return Theme.of(context).colorScheme.primary;
      case JobStatus.failed:
        return Theme.of(context).colorScheme.error;
      case JobStatus.pending:
      case JobStatus.processing:
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.secondary;
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 15.r),
              SizedBox(width: 6.w),
              Text(
                'TRANSLATED FILE READY',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Result filename',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8),
          ),
          SizedBox(height: 4.h),
          SelectableText(
            resultFileId,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              fontFamily: 'Courier',
            ),
          ),
          if (resultAssetId != null &&
              resultAssetId!.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Result asset ID',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8),
            ),
            SizedBox(height: 4.h),
            SelectableText(
              resultAssetId!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                fontFamily: 'Courier',
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (isCompleted)
                FilledButton.icon(
                  onPressed: isDownloading ? null : onDownload,
                  style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  textStyle: TextStyle(
                    fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                  icon: isDownloading
                    ? SizedBox(
                      width: 13.w,
                      height: 13.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary),
                    )
                    : Icon(Icons.download_rounded, size: 15.r),
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
            SizedBox(height: 10.h),
            const _InlineBanner(
              color: Colors.amber,
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
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        textStyle:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),
      icon: Icon(Icons.copy_outlined, size: 13.r),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 11.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: color, fontSize: 12.sp, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
