import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/search_result_item.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';

class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));
    final response = state.searchResponse;

    if (response == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      title: 'Search Results',
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                response.searchResults.isEmpty
                    ? 'No matching chunks were returned.'
                    : '${response.searchResults.length} result(s) for "${response.query}".',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (response.executionTimeMs != null)
              Text(
                '${response.executionTimeMs} ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        if (response.searchResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (var index = 0; index < response.searchResults.length; index++) ...[
            _SearchResultCard(
              item: response.searchResults[index],
              index: index,
              isExpanded: state.expandedSearchIndex == index,
              onToggle: () => ref
                  .read(ragNotifierProvider(projectId).notifier)
                  .toggleSearchResultExpansion(index),
            ),
            if (index < response.searchResults.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  final SearchResultItem item;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.getScoreColor(item.score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.score.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Spacer(),
              if (item.id != null)
                Text(
                  item.id!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.text,
            maxLines: isExpanded ? null : 4,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            label: Text(isExpanded ? 'Hide details' : 'Show details'),
          ),
          if (isExpanded && item.metaData.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Metadata',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            for (final entry in item.metaData.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: '${entry.value}'),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
