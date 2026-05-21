import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/rag_provider.dart';
class AnswerSection extends ConsumerWidget {
  const AnswerSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(ragStateProvider(projectId));
    final notifier = ref.read(ragNotifierProvider(projectId).notifier);

    return RSection(
      label: 'Ask AI',
      icon: Icons.auto_awesome_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask a question about the indexed knowledge in project $projectId.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),

          // ── Question field ────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            minLines: 3,
            maxLines: 6,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: 'Your question',
              hintText: 'Ask anything about your uploaded knowledge…',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 52.h),
                child: Icon(Icons.help_outline_rounded,
                    size: 18.r, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
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
            onChanged: notifier.updateQuestion,
          ),
          SizedBox(height: 12.h),

          // ── Limit field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: 'Retrieved chunks limit',
              hintText: state.answerLimit.toString(),
              helperText:
                  'Range: ${ValidationConstants.minRagLimit}–${ValidationConstants.maxRagLimit}',
              helperStyle:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
              errorText: state.answerLimitError,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: Icon(Icons.layers_outlined,
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
            onChanged: notifier.updateAnswerLimit,
          ),

          // ── Error ─────────────────────────────────────────────────
          if (state.answerErrorMessage != null) ...[
            SizedBox(height: 12.h),
            RAlertBanner(
              icon: Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              message: state.answerErrorMessage!,
            ),
          ],
          SizedBox(height: 16.h),

          // ── Submit ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  (state.isBusy || !state.canAsk) ? null : notifier.askQuestion,
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
              icon: state.isAnswering
                  ?  SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.auto_awesome_rounded, size: 18.r),
              label: Text(state.isAnswering ? 'Thinking…' : 'Ask'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared section wrapper ─────────────────────────────────────────────────
class RSection extends StatelessWidget {
  const RSection({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16.r),
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: iconColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20.h),
          child,
        ],
      ),
    );
  }
}

// ─── Alert banner ────────────────────────────────────────────────────────────
class RAlertBanner extends StatelessWidget {
  const RAlertBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
