import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/search_result_item.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';
import '../../../../l10n/l10n.dart';

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
      title: context.l10n.searchResultsTitle,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                response.searchResults.isEmpty
                    ? context.l10n.noMatchingChunks
                    : context.l10n.resultsForQuery(response.searchResults.length.toString(), response.query ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (response.executionTimeMs != null)
              Text(
                context.l10n.ms(response.executionTimeMs.toString()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        if (response.searchResults.isNotEmpty) ...[
          SizedBox(height: 16.h),
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
              SizedBox(height: 12.h),
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
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
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
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
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
          SizedBox(height: 10.h),
          Text(
            item.text,
            maxLines: isExpanded ? null : 4,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            label: Text(isExpanded ? context.l10n.hideDetails : context.l10n.showDetails),
          ),
          if (isExpanded && item.metaData.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              context.l10n.metadata,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 8.h),
            for (final entry in item.metaData.entries)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
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
