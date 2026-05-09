import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/translation_provider.dart';
import 'language_selector_widget.dart';

class JobCreationSection extends ConsumerWidget {
  const JobCreationSection({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier = ref.read(translationNotifierProvider(projectId).notifier);
    final featureColor = AppTheme.getFeatureColor('translate');
    final createdJob = state.createdJobResponse;

    return AppCard(
      title: 'Create Translation Job',
      children: [
        Text(
          'Submit a translation request for a file in project $projectId.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: !state.isBusy,
          onChanged: notifier.updateFileId,
          decoration: InputDecoration(
            labelText: 'File ID',
            hintText: 'Enter the file ID returned by upload',
            helperText:
                'Supported source assets include ${SupportedFileTypes.extensions.join(', ')}.',
            errorText: state.fileIdError,
          ),
        ),
        const SizedBox(height: 16),
        LanguageSelectorWidget(projectId: projectId),
        if (state.creationError != null) ...[
          const SizedBox(height: 12),
          Text(
            state.creationError!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.errorColor),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Create Job',
            icon: Icons.playlist_add_check_circle_outlined,
            onPressed: notifier.createTranslationJob,
            isLoading: state.isCreatingJob,
            isEnabled: state.canCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (createdJob != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: featureColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: featureColor.withOpacity(0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest created job',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  createdJob.jobId,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${createdJob.status} | Asset: ${createdJob.assetId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Route: ${LanguageCodes.getLanguageName(createdJob.sourceLang)} -> ${LanguageCodes.getLanguageName(createdJob.targetLang)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
