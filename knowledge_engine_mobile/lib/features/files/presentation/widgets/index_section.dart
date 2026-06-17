import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/files_provider.dart';
import 'upload_section.dart'; // FSection
import 'process_section.dart'; // _DarkCheckTile, _AdvancedPanel
import '../../../../core/theme/app_radius.dart';
import '../../../../l10n/l10n.dart';

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
      label: context.l10n.updateKnowledgeBase,
      icon: Icons.publish_rounded,
      isComplete: state.indexResponse != null,
      isLocked: locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            locked
              ? context.l10n.finishPreparingDocument
              : context.l10n.makeDocumentAvailable,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.sp),
            ),
          SizedBox(height: 16.h),

          // ── Full rebuild checkbox (inside advanced) ─────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.07)),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
              childrenPadding:
                  EdgeInsets.fromLTRB(14.w, 0.h, 14.w, 14.h),
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Icon(Icons.tune_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color, size: 17.r),
              title: Text(
                'Advanced',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Only needed for full rebuilds',
                style:
                    TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
              ),
              children: [
                DarkCheckTile(
                  value: state.indexDoReset,
                  disabled: state.isBusy,
                  title: 'Rebuild from scratch',
                  subtitle:
                      'Clears and rebuilds everything (slower). Use this after re-preparing the file.',
                  onChanged: (v) =>
                      notifier.toggleIndexDoReset(v ?? false),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

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
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                icon: state.isIndexing
                  ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                  )
                  : Icon(Icons.publish_rounded, size: 18.r),
              label:
                  Text(state.isIndexing ? 'Indexing…' : 'Update knowledge base'),
            ),
          ),

          // ── Index result ────────────────────────────────────────
          if (state.indexResponse != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 16.r),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      state.indexResponse!.indexedCount == null
                          ? 'Your document is ready to answer questions.'
                          : 'Your document is ready — ${state.indexResponse!.indexedCount} sections added.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13.sp,
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
