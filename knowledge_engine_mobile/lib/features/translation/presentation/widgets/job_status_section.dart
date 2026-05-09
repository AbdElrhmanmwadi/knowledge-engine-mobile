import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/translation_provider.dart';
import 'translation_status_card.dart';

class JobStatusSection extends ConsumerWidget {
  const JobStatusSection({
    super.key,
    required this.projectId,
  });

  final int projectId;

  static const List<int> _refreshOptions = <int>[1, 3, 5, 10, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier = ref.read(translationNotifierProvider(projectId).notifier);
    final featureColor = AppTheme.getFeatureColor('translate');
    final latestJobId = state.createdJobResponse?.jobId;

    return AppCard(
      title: 'Check Job Status',
      children: [
        Text(
          'Refresh the latest translation status manually or keep it polling automatically.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: !state.isBusy,
          onChanged: notifier.updateJobStatusId,
          decoration: InputDecoration(
            labelText: 'Job ID',
            hintText: 'Enter a job ID to inspect',
            helperText: latestJobId == null
                ? 'If left empty, the section uses the latest created job automatically.'
                : 'Latest created job: $latestJobId',
            errorText: state.jobStatusIdError,
          ),
        ),
        if (state.statusError != null) ...[
          const SizedBox(height: 12),
          Text(
            state.statusError!,
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
            label: 'Check Status',
            icon: Icons.refresh,
            onPressed: notifier.checkJobStatus,
            isLoading: state.isCheckingStatus,
            isEnabled: state.canCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: state.autoRefreshEnabled,
          onChanged: (value) => notifier.toggleAutoRefresh(value),
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-refresh'),
          subtitle: Text(
            'Refresh every ${state.refreshIntervalSeconds} seconds until the job completes.',
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: state.refreshIntervalSeconds,
          decoration: const InputDecoration(
            labelText: 'Refresh interval',
          ),
          items: _refreshOptions
              .map(
                (seconds) => DropdownMenuItem<int>(
                  value: seconds,
                  child: Text('$seconds seconds'),
                ),
              )
              .toList(growable: false),
          onChanged: state.isBusy
              ? null
              : (value) {
                  if (value != null) {
                    notifier.updateRefreshInterval(value);
                  }
                },
        ),
        if (state.hasVisibleStatusCard) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (state.canCheck)
                TextButton.icon(
                  onPressed: notifier.checkJobStatus,
                  icon: const Icon(Icons.sync),
                  label: const Text('Refresh now'),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: notifier.clearJob,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TranslationStatusCard(projectId: projectId),
        ],
      ],
    );
  }
}
