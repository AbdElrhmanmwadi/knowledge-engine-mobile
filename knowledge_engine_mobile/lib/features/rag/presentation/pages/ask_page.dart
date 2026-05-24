import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../../../../l10n/l10n.dart';
import '../providers/rag_provider.dart';
import '../widgets/answer_display_widget.dart';
import '../widgets/answer_section.dart';
import '../widgets/debug_section_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_section.dart';

/// Ask Page - Semantic search and RAG question answering
///
// Local `RColors` removed — use Theme / AppColors instead
class AskPage extends ConsumerStatefulWidget {
  const AskPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<AskPage> createState() => _AskPageState();
  
}

class _AskPageState extends ConsumerState<AskPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ragStateProvider(widget.projectId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: CustomScrollView(
          slivers: [
            // ── Collapsing hero app bar ───────────────────────────
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 210.h,
              pinned: true,
              elevation: 0,
              title: Text(
                context.l10n.askPageTitle,
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
                background: _AskHero(
                  projectId: widget.projectId,
                  waveController: _waveController,
                ),
              ),
            ),

            // ── Page body ─────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search
                  SearchSection(projectId: widget.projectId),
                  _Gap(),
                  SearchResultsWidget(projectId: widget.projectId),
                  _Gap(),

                  // Divider between search and ask
                  _FeatureDivider(
                    leftLabel: context.l10n.askLeftLabel,
                    rightLabel: context.l10n.askRightLabel,
                    leftColor: Theme.of(context).colorScheme.secondary,
                    rightColor: Theme.of(context).colorScheme.primary,
                  ),
                  _Gap(),

                  // Ask
                  AnswerSection(projectId: widget.projectId),
                  _Gap(),
                  AnswerDisplayWidget(projectId: widget.projectId),
                  _Gap(),
                  DebugSectionWidget(projectId: widget.projectId),

                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Hero header ─────────────────────────────────────────────────────────────
class _AskHero extends StatelessWidget {
  const _AskHero({
    required this.projectId,
    required this.waveController,
  });

  final int projectId;
  final AnimationController waveController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient — theme-aware blend
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
              ],
            ),
          ),
        ),
        // Animated waves
        AnimatedBuilder(
          animation: waveController,
          builder: (_, _) => CustomPaint(
            painter: _AskWavePainter(
              progress: waveController.value,
              color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
              color2: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dual feature badges
              Row(
                children: [
                  _HeroBadge(label: context.l10n.askLeftLabel.toUpperCase(), color: Theme.of(context).colorScheme.secondary),
                  SizedBox(width: 8.w),
                  _HeroBadge(label: context.l10n.askRightLabel.toUpperCase(), color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8.w),
                  _HeroBadge(label: context.l10n.projectBadge(projectId), color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                context.l10n.askHeroTitle(projectId),
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
                context.l10n.askHeroSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ── Wave painter ─────────────────────────────────────────────────────────────
class _AskWavePainter extends CustomPainter {
  const _AskWavePainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  final double progress;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    void wave(Color color, double amp, double speed, double offset) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      final phase = (progress * speed + offset) * 2 * math.pi;
      path.moveTo(0, size.height * 0.55);
      for (double x = 0; x <= size.width; x++) {
        final y = size.height * 0.55 +
            math.sin(x / size.width * 3 * math.pi + phase) * amp;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    wave(color1, 15, 0.6, 0.0);
    wave(color1.withValues(alpha: 0.5), 9, 1.1, 0.5);
    wave(color2, 19, 0.45, 0.9);
    wave(color2.withValues(alpha: 0.4), 7, 1.3, 1.4);
  }

  @override
  bool shouldRepaint(_AskWavePainter old) => old.progress != progress;
}

// ── Feature divider ──────────────────────────────────────────────────────────
class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
  });

  final String leftLabel;
  final String rightLabel;
  final Color leftColor;
  final Color rightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: leftColor.withValues(alpha: 0.2), thickness: 1)),
        SizedBox(width: 10.w),
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: leftColor)),
              SizedBox(width: 5.w),
              Text(leftLabel,
                  style: TextStyle(
                      color: leftColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(context.l10n.dotSeparator,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4))),
              ),
              Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: rightColor)),
              SizedBox(width: 5.w),
              Text(rightLabel,
                  style: TextStyle(
                      color: rightColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
            child: Divider(
                color: rightColor.withValues(alpha: 0.2), thickness: 1)),
      ],
    );
  }
}

// ── Gap helper ───────────────────────────────────────────────────────────────
class _Gap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(height: 14.h);
}
