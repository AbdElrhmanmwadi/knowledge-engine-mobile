import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/files_provider.dart';
import '../pages/files_page.dart';    // uses AppTheme
import 'upload_section.dart'; // FSection
import 'process_section.dart'; // _DarkCheckTile, _AdvancedPanel
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class IndexSection extends ConsumerWidget {
  const IndexSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(filesStateProvider(projectId));
    final notifier = ref.read(filesNotifierProvider(projectId).notifier);
    final locked  = state.processResponse == null;

    return FSection(
      stepNumber: 3,
      label: 'Update Knowledge Base',
      icon: Icons.publish_rounded,
      isComplete: state.indexResponse != null,
      isLocked: locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            locked
              ? 'Finish preparing the document first.'
              : 'Makes your prepared document available for search and answers.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
            ),
          const SizedBox(height: 16),

          // ── Full rebuild checkbox (inside advanced) ─────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.07)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding:
                  const EdgeInsets.fromLTRB(14, 0, 14, 14),
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Icon(Icons.tune_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color, size: 17),
              title: Text(
                'Advanced',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Only needed for full rebuilds',
                style:
                    TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11),
              ),
              children: [
                DarkCheckTile(
                  value: state.indexDoReset,
                  disabled: state.isBusy,
                  title: 'Full rebuild',
                  subtitle:
                      'Rebuilds the knowledge base from scratch (slower).',
                  onChanged: (v) =>
                      notifier.toggleIndexDoReset(v ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Index button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canIndex || locked)
                  ? null
                  : notifier.pushIndex,
                style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                disabledBackgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
                ),
                icon: state.isIndexing
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                  )
                  : const Icon(Icons.publish_rounded, size: 18),
              label:
                  Text(state.isIndexing ? 'Indexing…' : 'Update knowledge base'),
            ),
          ),

          // ── Index result ────────────────────────────────────────
          if (state.indexResponse != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.indexResponse!.indexedCount == null
                          ? 'Chunks were pushed to the vector database.'
                          : '${state.indexResponse!.indexedCount} chunks pushed to the vector database.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}