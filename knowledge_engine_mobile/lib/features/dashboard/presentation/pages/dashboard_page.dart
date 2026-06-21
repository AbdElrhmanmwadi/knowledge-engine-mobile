import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/directional_icon.dart';
import '../../../../core/widgets/wave_background.dart';
import '../../../../l10n/l10n.dart';

// Local design tokens removed — use Theme / AppColors instead

/// Dashboard Page — project hub with feature navigation.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.projectId});
  final int projectId;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 230.h,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              tooltip: context.l10n.goToProjects,
              icon: DirectionalIcon(Icons.arrow_back_rounded,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => context.go('/projects'),
            ),
            title: Text(
              context.l10n.workspaceTitle,
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
              background: _DashboardHero(
                projectId: widget.projectId,
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          SliverPadding(
            padding:
                 EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section label
                _Label(context.l10n.dashboardPrompt),
                 SizedBox(height: 14.h),

                // Feature cards grid (2 cols)
                _FeatureGrid(projectId: widget.projectId),

                 SizedBox(height: 24.h),




                 SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.projectId,
  });
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient bg — subtle multi-color blend
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        // Animated waves
        AnimatedWaves(
          duration: const Duration(seconds: 4),
          color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          color2: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
        // Content
        Positioned(
          bottom: 28,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Project badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  context.l10n.projectBadge(projectId),
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
                context.l10n.projectReadyTitle(projectId),
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
                context.l10n.projectReadySubtitle,
                style: TextStyle(
                  fontSize: 13,
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

// ── Feature grid ─────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
      final agentFeature = _Feature(
      title: context.l10n.featureAgentTitle,
      description: context.l10n.featureAgentDesc,
      icon: Icons.forum_rounded,
      color: Theme.of(context).colorScheme.primary,
      onTap: () => context.push('/agent', extra: projectId),
    );

    final features = [
      _Feature(
        title: context.l10n.documents,
        description: context.l10n.featureDocumentsDesc,
        icon: Icons.folder_open_rounded,
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => context.push('/files', extra: projectId),
      ),
      _Feature(
        title: context.l10n.askRightLabel,
        description: context.l10n.featureAskDesc,
        icon: Icons.auto_awesome_rounded,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/ask', extra: projectId),
      ),
      _Feature(
        title: context.l10n.featureVoiceTitle,
        description: context.l10n.featureVoiceDesc,
        icon: Icons.mic_rounded,
        color: Theme.of(context).colorScheme.tertiary ,
        onTap: () => context.push('/voice', extra: projectId),
      ),
      _Feature(
        title: context.l10n.translateHeroTitle(projectId),
        description: context.l10n.featureTranslateDesc,
        icon: Icons.translate_rounded,
        color: Theme.of(context).colorScheme.tertiaryContainer, 
        onTap: () => context.push('/translate', extra: projectId),
      ),
    ];

    return Column(
      children: [
        _FeatureCard(feature: agentFeature),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FeatureCard(feature: features[0])),
            const SizedBox(width: 12),
            Expanded(child: _FeatureCard(feature: features[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FeatureCard(feature: features[2])),
            const SizedBox(width: 12),
            Expanded(child: _FeatureCard(feature: features[3])),
          ],
        ),
      ],
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        f.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _pressed
            ? f.color.withValues(alpha: 0.12)
            : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pressed
                ? f.color.withValues(alpha: 0.4)
                : f.color.withValues(alpha: 0.18),
            width: _pressed ? 1.5 : 1,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: f.color.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: f.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: f.color.withValues(alpha: 0.25)),
              ),
              child:
                  Icon(f.icon, color: f.color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              f.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              f.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Arrow indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DirectionalIcon(
                    Icons.arrow_forward_rounded,
                    color: f.color,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
