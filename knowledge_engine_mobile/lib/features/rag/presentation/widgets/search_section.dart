import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knowledge_engine_mobile/features/rag/presentation/pages/ask_page.dart';

import '../../../../core/config/constants.dart';
import '../providers/rag_provider.dart';
import 'answer_section.dart'; // RSection, RAlertBanner


class SearchSection extends ConsumerWidget {
  const SearchSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(ragStateProvider(projectId));
    final notifier  = ref.read(ragNotifierProvider(projectId).notifier);

    return RSection(
      label: 'Search Knowledge',
      icon: Icons.manage_search_rounded,
      iconColor: RColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run semantic search against the indexed chunks in project $projectId.',
            style: const TextStyle(color: RColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── Query field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: RColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Search query',
              hintText: 'Find relevant chunks or concepts…',
              filled: true,
              fillColor: RColors.card,
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: RColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: RColors.purple, width: 1.5),
              ),
            ),
            onChanged: notifier.updateSearchQuery,
            onSubmitted: (_) => notifier.performSearch(),
          ),
          const SizedBox(height: 12),

          // ── Limit field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: RColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Result limit',
              hintText: state.searchLimit.toString(),
              helperText:
                  'Range: ${ValidationConstants.minSearchLimit}–${ValidationConstants.maxSearchLimit}',
              helperStyle: const TextStyle(
                  color: RColors.textSecondary, fontSize: 11),
              errorText: state.searchLimitError,
              filled: true,
              fillColor: RColors.card,
              prefixIcon: const Icon(Icons.format_list_numbered_rounded,
                  size: 18, color: RColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: RColors.purple, width: 1.5),
              ),
            ),
            onChanged: notifier.updateSearchLimit,
          ),

          // ── Error ─────────────────────────────────────────────────
          if (state.searchErrorMessage != null) ...[
            const SizedBox(height: 12),
            RAlertBanner(
              icon: Icons.error_outline_rounded,
              color: RColors.error,
              message: state.searchErrorMessage!,
            ),
          ],
          const SizedBox(height: 16),

          // ── Submit ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canSearch)
                  ? null
                  : notifier.performSearch,
              style: FilledButton.styleFrom(
                backgroundColor: RColors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: RColors.purple.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              icon: state.isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search_rounded, size: 18),
              label: Text(state.isSearching ? 'Searching…' : 'Search'),
            ),
          ),
        ],
      ),
    );
  }
}