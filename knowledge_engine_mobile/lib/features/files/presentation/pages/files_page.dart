import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/wave_background.dart';

import '../providers/files_provider.dart';
import '../widgets/index_section.dart';
import '../widgets/process_section.dart';
import '../widgets/status_log_widget.dart';
import '../widgets/upload_section.dart';
import '../../../../l10n/l10n.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
// Use centralized tokens from AppColors

/// Files Page — Upload → Prepare → Index workflow.
class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(filesStateProvider(widget.projectId));

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LoadingOverlay(
          isLoading: state.isBusy,
          message: state.activeLoadingMessage,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 210.h,
                pinned: true,
                elevation: 0,
                title: Text(
                  context.l10n.documents,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                centerTitle: false,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: _FilesHero(
                            projectId: widget.projectId,
                            currentStep: _currentStep(state),
                          ),
                        ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Error banner
                    if (state.errorMessage != null) ...[
                      _AlertBanner(
                          icon: Icons.error_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                          message: state.errorMessage!,
                        ),
                      SizedBox(height: 14.h),
                    ],

                    // Step progress tracker
                    _StepTracker(state: state),
                    SizedBox(height: 20.h),

                    // Sections
                    UploadSection(projectId: widget.projectId),
                    SizedBox(height: 14.h),
                    ProcessSection(projectId: widget.projectId),
                    SizedBox(height: 14.h),
                    IndexSection(projectId: widget.projectId),
                    SizedBox(height: 14.h),
                    StatusLogWidget(projectId: widget.projectId),
                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      
    );
  }

  int _currentStep(dynamic state) {
    if (state.indexResponse != null) return 3;
    if (state.processResponse != null) return 2;
    if (state.fileId != null) return 1;
    return 0;
  }

  // Page-specific theme removed; rely on AppTheme and Theme.of(context)
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _FilesHero extends StatelessWidget {
  const _FilesHero({
    required this.projectId,
    required this.currentStep,
  });

  final int projectId;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        AnimatedWaves(
          color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
          color2: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.32)),
                    ),
                      child: Text(
                        context.l10n.projectBadge(projectId),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (currentStep == 3)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.32)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary, size: 11.r),
                          SizedBox(width: 4.w),
                          Text(
                context.l10n.ready,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                context.l10n.addYourDocuments(projectId),
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.l10n.uploadPrepareIndexSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step progress tracker ────────────────────────────────────────────────────
class _StepTracker extends StatelessWidget {
  const _StepTracker({required this.state});
  final dynamic state;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(label: context.l10n.stepUpload, icon: Icons.upload_file_rounded),
      _StepData(label: context.l10n.stepPrepare, icon: Icons.auto_awesome_motion_outlined),
      _StepData(label: context.l10n.stepIndex, icon: Icons.publish_rounded),
    ];

    final current = state.indexResponse != null
        ? 3
        : state.processResponse != null
            ? 2
            : state.fileId != null
                ? 1
                : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _StepDot(
                data: steps[i],
                index: i,
                current: current,
              ),
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 1.5,
                  margin: EdgeInsets.only(bottom: 18.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        i < current
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2),
                        (i + 1) <= current
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.data,
    required this.index,
    required this.current,
  });
  final _StepData data;
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done    = index < current;
    final active  = index == current;
    final pending = index > current;

    final Color dotColor = done || active
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.3);

    return Column(
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
            border: Border.all(
              color: dotColor,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Icon(
            done ? Icons.check_rounded : data.icon,
            size: 16.r,
            color: dotColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          data.label,
            style: TextStyle(
            color: pending
                ? Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.4)
                : active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium!.color,
            fontSize: 11.sp,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Alert banner ─────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  const _AlertBanner(
      {required this.icon, required this.color, required this.message});
  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(message,
                style:
                    TextStyle(color: color, fontSize: 12.sp, height: 1.45)),
          ),
        ],
      ),
    );
  }
}
