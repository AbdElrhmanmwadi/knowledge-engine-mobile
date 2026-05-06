import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/files_provider.dart';

class IndexSection extends ConsumerWidget {
  const IndexSection({
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
      title: '3. Push to Index',
      children: [
        Text(
          state.processResponse == null
              ? 'Processing must finish before indexing becomes available.'
              : 'Push processed chunks into the vector database for retrieval.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: state.indexDoReset,
          onChanged: state.isBusy
              ? null
              : (value) => notifier.toggleIndexDoReset(value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Full reindex (do_reset)'),
          subtitle: const Text('Rebuild the vector collection from scratch.'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Push Index',
            icon: Icons.publish_outlined,
            onPressed: notifier.pushIndex,
            isLoading: state.isIndexing,
            isEnabled: state.canIndex,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (state.indexResponse != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const StatusBadge(
                status: 'success',
                label: 'Indexed',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.indexResponse!.indexedCount == null
                      ? 'Chunks were pushed to the vector database.'
                      : '${state.indexResponse!.indexedCount} chunks were pushed to the vector database.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
