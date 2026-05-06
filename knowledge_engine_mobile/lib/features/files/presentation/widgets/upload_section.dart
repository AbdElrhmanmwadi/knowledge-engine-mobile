import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/files_provider.dart';

class UploadSection extends ConsumerWidget {
  const UploadSection({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filesStateProvider(projectId));
    final notifier = ref.read(filesNotifierProvider(projectId).notifier);
    final featureColor = AppTheme.getFeatureColor('files');

    return AppCard(
      title: '1. Upload File',
      children: [
        Text(
          'Choose a supported file and upload it to project ${state.currentProjectId}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Choose File',
                icon: Icons.attach_file,
                isOutlined: true,
                onPressed: notifier.selectFile,
                isEnabled: !state.isBusy,
                style: OutlinedButton.styleFrom(
                  foregroundColor: featureColor,
                  side: BorderSide(color: featureColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Upload',
                icon: Icons.cloud_upload_outlined,
                onPressed: notifier.uploadFile,
                isLoading: state.isUploading,
                isEnabled: state.canUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: featureColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SelectedFileTile(fileName: state.selectedFileName),
        if (state.isUploading || state.uploadProgress > 0) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.uploadProgress.clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: featureColor,
            backgroundColor: featureColor.withOpacity(0.12),
          ),
          const SizedBox(height: 8),
          Text(
            '${(state.uploadProgress * 100).toStringAsFixed(0)}% uploaded',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (state.fileId != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: featureColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: featureColor.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploaded file ID',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  state.fileId!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SupportedFileTypes.extensions.map((extension) {
            return Chip(
              label: Text(extension),
              backgroundColor: featureColor.withOpacity(0.08),
              side: BorderSide(color: featureColor.withOpacity(0.2)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SelectedFileTile extends StatelessWidget {
  const _SelectedFileTile({
    required this.fileName,
  });

  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final hasSelection = fileName != null && fileName!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasSelection
            ? AppTheme.secondaryColor.withOpacity(0.06)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasSelection
              ? AppTheme.secondaryColor.withOpacity(0.18)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasSelection ? Icons.insert_drive_file_outlined : Icons.info_outline,
            color:
                hasSelection ? AppTheme.secondaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasSelection ? fileName! : 'No file selected yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
