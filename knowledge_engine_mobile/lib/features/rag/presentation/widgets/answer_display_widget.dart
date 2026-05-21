import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rag_provider.dart';

class AnswerDisplayWidget extends ConsumerWidget {
  const AnswerDisplayWidget({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(ragStateProvider(projectId));
    final response = state.answerResponse;

    if (response == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0.h),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 15.r),
                SizedBox(width: 8.w),
                Text(
                  'AI ANSWER',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (response.retrievedChunks != null)
                  _MiniPill(
                    label: '${response.retrievedChunks} chunks',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20.h),

          // ── Answer body ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0.h, 18.w, 0.h),
            child: SelectableText(
              response.answer,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14.sp,
                height: 1.7,
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // ── Signal + actions ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0.h, 18.w, 16.h),
            child: Row(
              children: [
                _MiniPill(
                  label: 'Signal: ${response.signal}',
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface,
                ),
                const Spacer(),
                // Copy
                _IconAction(
                  icon: Icons.copy_outlined,
                  label: 'Copy',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => _copy(
                    context,
                    response.answer,
                    'Answer copied to clipboard.',
                  ),
                ),
                if (state.hasDebugData) ...[
                  SizedBox(width: 8.w),
                  _IconAction(
                    icon: state.isDebugVisible
                        ? Icons.visibility_off_outlined
                        : Icons.bug_report_outlined,
                    label: state.isDebugVisible ? 'Hide debug' : 'Debug',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: ref
                        .read(ragNotifierProvider(projectId).notifier)
                        .toggleDebugVisibility,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(label)));
  }
}

// ── Mini pill ───────────────────────────────────────────────────────────────
class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Icon action button ───────────────────────────────────────────────────────
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14.r),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
