import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_toggle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

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
    _controller   = TextEditingController();
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
    final stateAsync    = ref.watch(projectsNotifierProvider);
    final notifier      = ref.read(projectsNotifierProvider.notifier);
    final recentProjects = ref.watch(recentProjectsProvider);

    return stateAsync.when(
        loading: () => _shell(context, child: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        )),
        error: (e, _) => _shell(context, child: Center(
          child: Text('Error: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        )),
        data: (state) {
          // Sync controller
          if (_controller.text != state.projectInput) {
            _controller.value = _controller.value.copyWith(
              text: state.projectInput,
              selection: TextSelection.collapsed(
                  offset: state.projectInput.length),
              composing: TextRange.empty,
            );
          }

          return _shell(context,
            child: CustomScrollView(
              slivers: [
                // ── Collapsing hero ──────────────────────────────────
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  expandedHeight: 220,
                  pinned: true,
                  elevation: 0,
                  title: Text(
                    'Knowledge Engine',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  centerTitle: false,
                  actions: const [
                    ThemeToggleButton(),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _Hero(waveController: _waveController),
                  ),
                ),

                // ── Body ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Error banner
                              if (state.errorMessage != null) ...[
                                _AlertBanner(
                                    icon: Icons.error_outline_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                    message: state.errorMessage!),
                        const SizedBox(height: 14),
                      ],

                      // ── Project ID input ─────────────────────────
                      _SectionLabel(label: 'Open Project'),
                      const SizedBox(height: 12),
                      _ProjectInputCard(
                        controller: _controller,
                        state: state,
                        notifier: notifier,
                        onOpen: (id) =>
                            context.push('/dashboard', extra: id),
                      ),

                      const SizedBox(height: 28),

                      // ── Recent projects ──────────────────────────
                      _SectionLabel(label: 'Recent Projects'),
                      const SizedBox(height: 12),
                      _RecentProjectsList(
                        recentProjects: recentProjects,
                        notifier: notifier,
                        onTap: (id) =>
                            context.push('/dashboard', extra: id),
                        onDelete: (id) async {
                          final ok =
                              await notifier.deleteProject(id);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                  'Couldn\'t delete Project $id.'),
                            ));
                          }
                          return ok;
                        },
                      ),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      
    );
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
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
            builder: (_, __) => CustomPaint(
            painter: _WavePainter(
              progress: waveController.value,
              color1: Theme.of(context).colorScheme.primary.withOpacity(0.16),
              color2: Theme.of(context).colorScheme.secondary.withOpacity(0.09),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.32)),
                ),
                child: Text(
                  'KNOWLEDGE ENGINE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your projects,\nat a glance',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter a project ID or pick a recent one',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
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
  const _WavePainter(
      {required this.progress, required this.color1, required this.color2});
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
        path.lineTo(x,
            size.height * 0.6 + math.sin(x / size.width * 3 * math.pi + phase) * amp);
      }
      canvas.drawPath(path, p);
    }

    wave(color1, 14, 0.55, 0.0);
    wave(color1.withOpacity(0.5), 9, 1.0, 0.5);
    wave(color2, 18, 0.4, 1.0);
    wave(color2.withOpacity(0.4), 6, 1.2, 1.5);
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w500),
            onChanged: notifier.updateProjectInput,
            onSubmitted: (_) => _submit(context),
            decoration: InputDecoration(
              labelText: 'Project ID',
              hintText: 'e.g. 42',
              errorText: state.validationError,
                prefixIcon: Icon(Icons.folder_outlined,
                  size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                suffixIcon: state.projectInput.trim().isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.close_rounded,
                      size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                    tooltip: 'Clear',
                    onPressed: () => notifier.updateProjectInput(''),
                  )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
              child: FilledButton.icon(
              onPressed: state.isLoading ? null : () => _submit(context),
              style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
              ),
              icon: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 18),
              label:
                  Text(state.isLoading ? 'Opening…' : 'Open Project'),
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
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      error: (e, _) => _AlertBanner(
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        message: 'Error loading recent projects: $e',
      ),
      data: (projects) {
        if (projects.isEmpty) {
                return Container(
            padding: const EdgeInsets.symmetric(
                vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.07)),
            ),
            child: Column(
              children: [
                Icon(Icons.folder_off_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                    size: 36),
                const SizedBox(height: 10),
                Text(
                  'No recent projects yet',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open a project above to see it here',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontSize: 11),
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
              if (i < projects.length - 1)
                const SizedBox(height: 8),
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
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) => onDelete(),
      background: _SwipeBackground(
          alignment: Alignment.centerLeft),
      secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: color.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              // Colour dot / folder icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: color.withOpacity(0.25)),
                ),
                child: Icon(Icons.folder_rounded,
                    color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project #$projectId',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to open · swipe to delete',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
                Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                  size: 20),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: isLeft
      ? [
        Icon(Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error, size: 20),
        const SizedBox(width: 6),
        Text('Delete',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
            fontSize: 13)),
        ]
      : [
        Text('Delete',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
            fontSize: 13)),
        const SizedBox(width: 6),
        Icon(Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error, size: 20),
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner(
      {required this.icon, required this.color, required this.message});
  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: color, fontSize: 12, height: 1.45)),
          ),
        ],
      ),
    );
  }
}