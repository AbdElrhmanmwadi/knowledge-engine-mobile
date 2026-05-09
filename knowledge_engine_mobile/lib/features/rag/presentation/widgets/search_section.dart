import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';

class SearchSection extends ConsumerWidget {
  const SearchSection({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));
    final notifier = ref.read(ragNotifierProvider(projectId).notifier);
    final featureColor = AppTheme.getFeatureColor('search');

    return AppCard(
      title: 'Search Knowledge',
      children: [
        Text(
          'Run semantic search against the indexed chunks in project $projectId.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: !state.isBusy,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Search query',
            hintText: 'Find relevant chunks or concepts',
          ),
          onChanged: notifier.updateSearchQuery,
          onSubmitted: (_) => notifier.performSearch(),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: !state.isBusy,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: 'Result limit',
            hintText: state.searchLimit.toString(),
            helperText:
                'Range: ${ValidationConstants.minSearchLimit}-${ValidationConstants.maxSearchLimit}',
            errorText: state.searchLimitError,
          ),
          onChanged: notifier.updateSearchLimit,
        ),
        if (state.searchErrorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.searchErrorMessage!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Search',
            icon: Icons.search,
            onPressed: notifier.performSearch,
            isLoading: state.isSearching,
            isEnabled: state.canSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
