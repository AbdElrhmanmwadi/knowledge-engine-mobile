import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      iconColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run semantic search against the indexed chunks in project $projectId.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),

          // ── Query field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: 'Search query',
              hintText: 'Find relevant chunks or concepts…',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: Icon(Icons.search_rounded,
                  size: 18.r, color: Theme.of(context).textTheme.bodyMedium?.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
            ),
            onChanged: notifier.updateSearchQuery,
            onSubmitted: (_) => notifier.performSearch(),
          ),
          SizedBox(height: 12.h),

          // ── Limit field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: 'Result limit',
              hintText: state.searchLimit.toString(),
              helperText:
                  'Range: ${ValidationConstants.minSearchLimit}–${ValidationConstants.maxSearchLimit}',
              helperStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
              errorText: state.searchLimitError,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: Icon(Icons.format_list_numbered_rounded,
                  size: 18.r, color: Theme.of(context).textTheme.bodyMedium?.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
            ),
            onChanged: notifier.updateSearchLimit,
          ),

          // ── Error ─────────────────────────────────────────────────
          if (state.searchErrorMessage != null) ...[
            SizedBox(height: 12.h),
            RAlertBanner(
              icon: Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              message: state.searchErrorMessage!,
            ),
          ],
          SizedBox(height: 16.h),

          // ── Submit ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canSearch)
                  ? null
                  : notifier.performSearch,
              style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              textStyle: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              icon: state.isSearching
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.search_rounded, size: 18.r),
              label: Text(state.isSearching ? 'Searching…' : 'Search'),
            ),
          ),
        ],
      ),
    );
  }
}
