import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/language_toggle.dart';
import '../../../../core/theme/theme_toggle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../l10n/l10n.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/projects_notifier.dart';
import '../providers/recent_projects_provider.dart';

// centralized tokens via AppColors/AppSpacing/AppRadius

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // No page-local theme — use centralized AppTheme

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(projectsNotifierProvider);
    final notifier = ref.read(projectsNotifierProvider.notifier);
    final recentProjects = ref.watch(recentProjectsProvider);
    final l10n = context.l10n;

    return stateAsync.when(
      loading: () => _shell(
        context,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      error: (e, _) => _shell(
        context,
        child: Center(
          child: Text(
            l10n.errorWithMessage(e.toString()),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      data: (state) {
        // Sync controller
        if (_controller.text != state.projectInput) {
          _controller.value = _controller.value.copyWith(
            text: state.projectInput,
            selection: TextSelection.collapsed(
              offset: state.projectInput.length,
            ),
            composing: TextRange.empty,
          );
        }

        return _shell(
          context,
          child: CustomScrollView(
            slivers: [
              // ── Collapsing hero ──────────────────────────────────
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 220.h,
                pinned: true,
                elevation: 0,
                title: Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                centerTitle: false,
                actions: [
                  const LanguageToggleButton(),
                  const ThemeToggleButton(),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, size: 20.r),
                    tooltip: l10n.logout,
                    onPressed: _confirmLogout,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _Hero(waveController: _waveController),
                ),
              ),

              // ── Body ─────────────────────────────────────────────
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

                    // ── Project ID input ─────────────────────────
                    _SectionLabel(label: l10n.openProject),
                    SizedBox(height: 12.h),
                    _ProjectInputCard(
                      controller: _controller,
                      state: state,
                      notifier: notifier,
                      onOpen: (id) => context.push('/dashboard', extra: id),
                    ),

                    SizedBox(height: 28.h),

                    // ── Recent projects ──────────────────────────
                    _SectionLabel(label: l10n.recentProjects),
                    SizedBox(height: 12.h),
                    _RecentProjectsList(
                      recentProjects: recentProjects,
                      notifier: notifier,
                      onTap: (id) => context.push('/dashboard', extra: id),
                      onDelete: (id) async {
                        final ok = await notifier.deleteProject(id);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.couldNotDeleteProject(id)),
                            ),
                          );
                        }
                        return ok;
                      },
                    ),

                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Routing back to /login is handled by the router's auth redirect.
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  Widget _shell(BuildContext context, {required Widget child}) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: child,
  );
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({required this.waveController});
  final AnimationController waveController;

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
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
          builder: (_, _) => CustomPaint(
            painter: _WavePainter(
              progress: waveController.value,
              color1: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.16),
              color2: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.09),
            ),
          ),
        ),
        Positioned(
          bottom: 28,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.32),
                  ),
                ),
                child: Text(
                  context.l10n.knowledgeEngineUpper,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                context.l10n.projectsHeroTitle,
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
                context.l10n.projectsHeroSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });
  final double progress;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    void wave(Color c, double amp, double speed, double offset) {
      final p = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      final phase = (progress * speed + offset) * 2 * math.pi;
      path.moveTo(0, size.height * 0.6);
      for (double x = 0; x <= size.width; x++) {
        path.lineTo(
          x,
          size.height * 0.6 +
              math.sin(x / size.width * 3 * math.pi + phase) * amp,
        );
      }
      canvas.drawPath(path, p);
    }

    wave(color1, 14, 0.55, 0.0);
    wave(color1.withValues(alpha: 0.5), 9, 1.0, 0.5);
    wave(color2, 18, 0.4, 1.0);
    wave(color2.withValues(alpha: 0.4), 6, 1.2, 1.5);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// ── Project input card ───────────────────────────────────────────────────────
class _ProjectInputCard extends StatelessWidget {
  const _ProjectInputCard({
    required this.controller,
    required this.state,
    required this.notifier,
    required this.onOpen,
  });

  final TextEditingController controller;
  final ProjectsState state;
  final ProjectsNotifier notifier;
  final void Function(int id) onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            onChanged: notifier.updateProjectInput,
            onSubmitted: (_) => _submit(context),
            decoration: InputDecoration(
              labelText: context.l10n.projectId,
              hintText: context.l10n.projectIdHint,
              errorText: state.validationError,
              prefixIcon: Icon(
                Icons.folder_outlined,
                size: 18.r,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              suffixIcon: state.projectInput.trim().isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.r,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      tooltip: context.l10n.clear,
                      onPressed: () => notifier.updateProjectInput(''),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isLoading ? null : () => _submit(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                disabledBackgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: state.isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.arrow_forward_rounded, size: 18.r),
              label: Text(
                state.isLoading
                    ? context.l10n.opening
                    : context.l10n.openProject,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    if (notifier.validateAndOpenProject()) {
      final id = int.tryParse(state.projectInput.trim());
      if (id != null) onOpen(id);
    }
  }
}

// ── Recent projects list ─────────────────────────────────────────────────────
class _RecentProjectsList extends StatelessWidget {
  const _RecentProjectsList({
    required this.recentProjects,
    required this.notifier,
    required this.onTap,
    required this.onDelete,
  });

  final AsyncValue<List<int>> recentProjects;
  final ProjectsNotifier notifier;
  final void Function(int id) onTap;
  final Future<bool> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return recentProjects.when(
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      error: (e, _) => _AlertBanner(
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        message: context.l10n.errorLoadingRecentProjects(e.toString()),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.07),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_off_outlined,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                  size: 36.r,
                ),
                SizedBox(height: 10.h),
                Text(
                  context.l10n.noRecentProjects,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  context.l10n.openProjectAbove,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < projects.length; i++) ...[
              _RecentProjectTile(
                projectId: projects[i],
                index: i,
                onTap: () => onTap(projects[i]),
                onDelete: () => onDelete(projects[i]),
              ),
              if (i < projects.length - 1) SizedBox(height: 8.h),
            ],
          ],
        );
      },
    );
  }
}

// ── Single recent project tile ───────────────────────────────────────────────
class _RecentProjectTile extends StatelessWidget {
  const _RecentProjectTile({
    required this.projectId,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final int projectId;
  final int index;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  // Cycle through accent colours so tiles feel distinct
  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.purple,
    AppColors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];

    return Dismissible(
      key: ValueKey('project_$projectId'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: _SwipeBackground(alignment: Alignment.centerRight),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              // Colour dot / folder icon
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(Icons.folder_rounded, color: color, size: 20.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.projectNumber(projectId),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.tapToOpenSwipeToDelete,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.alignment});
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.35)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 20.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  context.l10n.delete,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ]
            : [
                Text(
                  context.l10n.delete,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 20.r,
                ),
              ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
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
