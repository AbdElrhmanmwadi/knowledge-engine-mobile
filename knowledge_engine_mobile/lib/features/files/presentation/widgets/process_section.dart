import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/files_provider.dart';
import '../pages/files_page.dart';    // uses AppTheme now
import 'upload_section.dart'; // FSection
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class ProcessSection extends ConsumerWidget {
  const ProcessSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(filesStateProvider(projectId));
    final notifier = ref.read(filesNotifierProvider(projectId).notifier);
    final locked  = state.fileId == null;

    return FSection(
      stepNumber: 2,
      label: 'Prepare Document',
      icon: Icons.auto_awesome_motion_outlined,
      isComplete: state.processResponse != null,
      isLocked: locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            locked
              ? 'Upload a file first to unlock this step.'
              : 'Prepares your document for search and question answering.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.sp),
            ),
          SizedBox(height: 16.h),

          // ── Replace previous checkbox ───────────────────────────
          DarkCheckTile(
            value: state.processDoReset,
            disabled: state.isBusy,
            title: 'Replace previous preparation',
            subtitle:
                'Use this if you re-uploaded or changed the file.',
            onChanged: (v) =>
                notifier.toggleProcessDoReset(v ?? false),
          ),
          SizedBox(height: 12.h),

          // ── Advanced settings ───────────────────────────────────
          _AdvancedPanel(
            isBusy: state.isBusy,
            isExpanded: state.showAdvancedOptions,
            onExpand: notifier.toggleAdvancedOptions,
            children: [
              _DarkTextField(
                label: 'Chunk size',
                hint: state.chunkSize.toString(),
                helper:
                    'Range: ${ValidationConstants.minChunkSize}–${ValidationConstants.maxChunkSize}',
                errorText: state.chunkSizeError,
                disabled: state.isBusy,
                onChanged: notifier.updateChunkSize,
              ),
              SizedBox(height: 12.h),
              _DarkTextField(
                label: 'Overlap size',
                hint: state.overlapSize.toString(),
                helper:
                    'Range: ${ValidationConstants.minOverlapSize}–${ValidationConstants.maxOverlapSize}',
                errorText: state.overlapSizeError,
                disabled: state.isBusy,
                onChanged: notifier.updateOverlapSize,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                    Icon(Icons.lightbulb_outline_rounded,
                      size: 13.r,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Only change these if you know what you\'re optimising for.',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Prepare button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canProcess || locked)
                  ? null
                  : notifier.processFile,
                style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                disabledBackgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              icon: state.isProcessing
                    ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                    )
                  : Icon(
                      Icons.auto_awesome_motion_outlined, size: 18.r),
              label: Text(state.isProcessing
                  ? 'Preparing…'
                  : 'Prepare document'),
            ),
          ),

          // ── Process result ──────────────────────────────────────
          if (state.processResponse != null) ...[
            SizedBox(height: 16.h),
            _ProcessResult(response: state.processResponse!),
          ],
        ],
      ),
    );
  }
}

// ── Process result card ──────────────────────────────────────────────────────
class _ProcessResult extends StatelessWidget {
  const _ProcessResult({required this.response});
  final dynamic response;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 14.r),
              SizedBox(width: 6.w),
              Text(
                'PROCESSING COMPLETE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MetricChip(
                label: 'Chunks inserted',
                value: response.insertedChunks.toString(),
              ),
              _MetricChip(
                label: 'Files processed',
                value: response.processedFiles.toString(),
              ),
              if (response.fileId != null)
                _MetricChip(
                  label: 'File ID',
                  value: response.fileId as String,
                  mono: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 10.sp),
          ),
          SizedBox(height: 3.h),
          SelectableText(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'Courier' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Advanced collapsible panel ───────────────────────────────────────────────
class _AdvancedPanel extends StatelessWidget {
  const _AdvancedPanel({
    required this.isBusy,
    required this.isExpanded,
    required this.onExpand,
    required this.children,
  });
  final bool isBusy;
  final bool isExpanded;
  final ValueChanged<bool>? onExpand;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.07)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
        childrenPadding: EdgeInsets.fromLTRB(14.w, 0.h, 14.w, 14.h),
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
          'Default settings work for most files',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: isBusy ? null : onExpand,
        children: children,
      ),
    );
  }
}

// ── Dark-styled checkbox tile ────────────────────────────────────────────────
class DarkCheckTile extends StatelessWidget {
  const DarkCheckTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.disabled = false,
  });
  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool?> onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.07)
              : Theme.of(context).cardColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: value
                ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                : Theme.of(context).dividerColor.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: Checkbox(
                value: value,
                onChanged: disabled ? null : onChanged,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dark text field ──────────────────────────────────────────────────────────
class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.label,
    required this.hint,
    required this.helper,
    required this.onChanged,
    this.errorText,
    this.disabled = false,
  });
  final String label;
  final String hint;
  final String helper;
  final String? errorText;
  final bool disabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: !disabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: errorText,
      ),
    );
  }
}
