import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/translation_provider.dart';
import '../widgets/job_creation_section.dart';
import '../widgets/job_status_section.dart';

// ── Shared design tokens (mirror voice_page.dart) ──────────────────────────
// shared tokens removed — use Theme / AppColors instead

/// Translate Page — redesigned to match Voice Page aesthetic.
class TranslatePage extends ConsumerStatefulWidget {
  const TranslatePage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends ConsumerState<TranslatePage>
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
    final state = ref.watch(translationStateProvider(widget.projectId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 210,
              pinned: true,
              elevation: 0,
              title: Text(
                'File Translation',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _TranslateHero(
                  projectId: widget.projectId,
                  waveController: _waveController,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  JobCreationSection(projectId: widget.projectId),
                  const SizedBox(height: 16),
                  JobStatusSection(projectId: widget.projectId),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Hero header ────────────────────────────────────────────────────────────
class _TranslateHero extends StatelessWidget {
  const _TranslateHero({
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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.08),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
            builder: (_, __) => CustomPaint(
            painter: _TranslateWavePainter(
              progress: waveController.value,
              color1: Theme.of(context).colorScheme.primary.withOpacity(0.18),
              color2: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.35)),
                ),
                child: Text(
                  'PROJECT $projectId',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Translate project\nfiles',
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
                'Create jobs · track progress · download results',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
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

class _TranslateWavePainter extends CustomPainter {
  const _TranslateWavePainter({
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

    wave(color1, 16, 0.6, 0);
    wave(color1.withOpacity(0.5), 10, 1.0, 0.5);
    wave(color2, 20, 0.4, 0.9);
    wave(color2.withOpacity(0.4), 7, 1.3, 1.3);
  }

  @override
  bool shouldRepaint(_TranslateWavePainter old) => old.progress != progress;
}