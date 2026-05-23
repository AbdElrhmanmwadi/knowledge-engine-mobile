import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/translation_provider.dart';
import '../../../../l10n/l10n.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier =
        ref.read(translationNotifierProvider(projectId).notifier);
    final items = LanguageCodes.getCodes();

    final sourceDropdown = _buildDropdown(
      context: context,
      label: context.l10n.sourceLanguage,
      value: state.sourceLang,
      items: items,
      disabled: state.isBusy,
      onChanged: (v) {
        if (v != null) notifier.updateSourceLang(v);
      },
    );

    final targetDropdown = _buildDropdown(
      context: context,
      label: context.l10n.targetLanguage,
      value: state.targetLang,
      items: items,
      disabled: state.isBusy,
      onChanged: (v) {
        if (v != null) notifier.updateTargetLang(v);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section micro-label ──────────────────────────────────────
        Row(
          children: [
            Icon(Icons.translate_rounded, size: 14.r, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 6.w),
            Text(
              context.l10n.languagesLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // ── Dropdowns ────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 480;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: sourceDropdown),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Icon(Icons.arrow_forward_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      size: 18.r),
                  ),
                  Expanded(child: targetDropdown),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sourceDropdown,
                SizedBox(height: 10.h),
                Center(
                  child: Icon(Icons.arrow_downward_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      size: 18.r),
                ),
                SizedBox(height: 10.h),
                targetDropdown,
              ],
            );
          },
        ),
        SizedBox(height: 12.h),

        // ── Route preview ─────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route_rounded,
                  size: 13.r, color: Theme.of(context).colorScheme.secondary),
              SizedBox(width: 7.w),
              Text(
                '${LanguageCodes.getLanguageName(state.sourceLang)} → ${LanguageCodes.getLanguageName(state.targetLang)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required bool disabled,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13.sp),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).textTheme.bodyMedium?.color, size: 18.r),
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
        ),
      ),
      items: items
          .map(
            (code) => DropdownMenuItem<String>(
              value: code,
              child: Text(LanguageCodes.getLanguageName(code)),
            ),
          )
          .toList(growable: false),
      onChanged: disabled ? null : onChanged,
    );
  }
}
