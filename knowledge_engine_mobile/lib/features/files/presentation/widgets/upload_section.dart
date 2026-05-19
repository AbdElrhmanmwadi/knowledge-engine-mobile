import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/files_provider.dart';
import '../pages/files_page.dart';    // FColors

class UploadSection extends ConsumerWidget {
  const UploadSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(filesStateProvider(projectId));
    final notifier = ref.read(filesNotifierProvider(projectId).notifier);

    return FSection(
      stepNumber: 1,
      label: 'Upload File',
      icon: Icons.upload_file_rounded,
      isComplete: state.fileId != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a supported file and upload it to project ${state.currentProjectId}.',
            style: const TextStyle(
                color: FColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── File picker + upload row ────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      state.isBusy ? null : notifier.selectFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FColors.accent,
                    side: BorderSide(
                        color: FColors.accent.withOpacity(0.45)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Choose file'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: (state.isBusy || !state.canUpload)
                      ? null
                      : notifier.uploadFile,
                  style: FilledButton.styleFrom(
                    backgroundColor: FColors.accent,
                    foregroundColor: FColors.bg,
                    disabledBackgroundColor:
                        FColors.accent.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  icon: state.isUploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: FColors.bg),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 16),
                  label: Text(
                      state.isUploading ? 'Uploading…' : 'Upload'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Selected file tile ──────────────────────────────────
          _SelectedFileTile(fileName: state.selectedFileName),

          // ── Upload progress ─────────────────────────────────────
          if (state.isUploading || state.uploadProgress > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: state.uploadProgress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor:
                          FColors.accent.withOpacity(0.12),
                      color: FColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(state.uploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: FColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // ── File ID result ──────────────────────────────────────
          if (state.fileId != null) ...[
            const SizedBox(height: 12),
            _ResultBadge(
              icon: Icons.check_circle_rounded,
              label: 'File ID',
              value: state.fileId!,
            ),
          ],

          // ── Supported types ─────────────────────────────────────
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SupportedFileTypes.extensions.map((ext) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: FColors.accent.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: FColors.accent.withOpacity(0.2)),
                ),
                child: Text(
                  ext,
                  style: const TextStyle(
                    color: FColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Selected file tile ───────────────────────────────────────────────────────
class _SelectedFileTile extends StatelessWidget {
  const _SelectedFileTile({required this.fileName});
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final has = fileName != null && fileName!.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: has
            ? FColors.accent.withOpacity(0.07)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: has
              ? FColors.accent.withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            has
                ? Icons.insert_drive_file_outlined
                : Icons.info_outline_rounded,
            color: has ? FColors.accent : FColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              has ? fileName! : 'No file selected yet.',
              style: TextStyle(
                color: has
                    ? FColors.textPrimary
                    : FColors.textSecondary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result badge (file ID, chunk count, etc.) ────────────────────────────────
class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: FColors.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FColors.accent.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: FColors.accent, size: 15),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
                color: FColors.textSecondary, fontSize: 12),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: FColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section wrapper ───────────────────────────────────────────────────
/// Exported so process_section, index_section can use it.
class FSection extends StatelessWidget {
  const FSection({
    super.key,
    required this.stepNumber,
    required this.label,
    required this.icon,
    required this.child,
    this.isComplete = false,
    this.isLocked = false,
  });

  final int stepNumber;
  final String label;
  final IconData icon;
  final Widget child;
  final bool isComplete;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final Color color = isComplete
        ? FColors.accent
        : isLocked
            ? FColors.textSecondary.withOpacity(0.4)
            : FColors.accent;

    return AnimatedOpacity(
      opacity: isLocked ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isComplete
                ? FColors.accent.withOpacity(0.25)
                : Colors.white.withOpacity(0.07),
            width: isComplete ? 1.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  alignment: Alignment.center,
                  child: isComplete
                      ? Icon(Icons.check_rounded,
                          size: 13, color: color)
                      : Text(
                          '$stepNumber',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isComplete) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: FColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: FColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Divider(
                color: Colors.white.withOpacity(0.06), height: 20),
            child,
          ],
        ),
      ),
    );
  }
}