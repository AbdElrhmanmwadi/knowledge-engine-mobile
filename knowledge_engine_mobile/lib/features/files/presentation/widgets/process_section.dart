import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/files_provider.dart';

class ProcessSection extends ConsumerWidget {
  const ProcessSection({
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
      title: '2. Prepare document',
      children: [
        Text(
          state.fileId == null
              ? 'Upload a file first to unlock this step.'
              : 'This prepares your document so it can be searched and used for answers.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text('Advanced'),
          subtitle: Text(
            'Default settings work for most files.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onExpansionChanged: state.isBusy ? null : notifier.toggleAdvancedOptions,
          initiallyExpanded: state.showAdvancedOptions,
          children: [
            const SizedBox(height: 8),
            TextField(
              enabled: !state.isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Chunk size',
                hintText: state.chunkSize.toString(),
                helperText:
                    'Range: ${ValidationConstants.minChunkSize}-${ValidationConstants.maxChunkSize}',
                errorText: state.chunkSizeError,
              ),
              onChanged: notifier.updateChunkSize,
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: !state.isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Overlap size',
                hintText: state.overlapSize.toString(),
                helperText:
                    'Range: ${ValidationConstants.minOverlapSize}-${ValidationConstants.maxOverlapSize}',
                errorText: state.overlapSizeError,
              ),
              onChanged: notifier.updateOverlapSize,
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Only change these if you know what you’re optimizing for.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: state.processDoReset,
          onChanged: state.isBusy
              ? null
              : (value) => notifier.toggleProcessDoReset(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Replace previous preparation'),
          subtitle: const Text('Use this if you re-uploaded or changed the file.'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Prepare document',
            icon: Icons.auto_awesome_motion_outlined,
            onPressed: notifier.processFile,
            isLoading: state.isProcessing,
            isEnabled: state.canProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (state.processResponse != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricTile(
                      label: 'Inserted chunks',
                      value: state.processResponse!.insertedChunks.toString(),
                    ),
                    _MetricTile(
                      label: 'Processed files',
                      value: state.processResponse!.processedFiles.toString(),
                    ),
                    if (state.processResponse!.fileId != null)
                      _MetricTile(
                        label: 'File ID',
                        value: state.processResponse!.fileId!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
