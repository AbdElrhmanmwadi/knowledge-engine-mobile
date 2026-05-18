import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../providers/rag_provider.dart';
import '../widgets/answer_display_widget.dart';
import '../widgets/answer_section.dart';
import '../widgets/debug_section_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_section.dart';

/// Ask Page - Semantic search and RAG question answering
/// 
class RColors {
  static const bg            = Color(0xFF0D0F14);
  static const surface       = Color(0xFF161923);
  static const card          = Color(0xFF1E2230);
  static const accent        = Color(0xFF6C8EFF); // indigo – Ask AI
  static const accentSoft    = Color(0xFF3D5AF1);
  static const purple        = Color(0xFFB07CFF); // Search
  static const purpleSoft    = Color(0xFF7B3FE4);
  static const teal          = Color(0xFF38EFC4); // success / result
  static const amber         = Color(0xFFFFB547); // warning / debug
  static const error         = Color(0xFFFF5C6B);
  static const textPrimary   = Color(0xFFF0F2FF);
  static const textSecondary = Color(0xFF8891B0);

  
}
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

    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        backgroundColor: RColors.bg,
        body: LoadingOverlay(
          isLoading: state.isBusy,
          message: state.activeLoadingMessage,
          child: CustomScrollView(
            slivers: [
              // ── Collapsing hero app bar ───────────────────────────
              SliverAppBar(
                backgroundColor: RColors.bg,
                expandedHeight: 210,
                pinned: true,
                elevation: 0,
                title: const Text(
                  'Ask & Search',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: RColors.textPrimary,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Search
                    SearchSection(projectId: widget.projectId),
                    _Gap(),
                    SearchResultsWidget(projectId: widget.projectId),
                    _Gap(),

                    // Divider between search and ask
                    _FeatureDivider(
                      leftLabel: 'Search',
                      rightLabel: 'Ask AI',
                      leftColor: RColors.purple,
                      rightColor: RColors.accent,
                    ),
                    _Gap(),

                    // Ask
                    AnswerSection(projectId: widget.projectId),
                    _Gap(),
                    AnswerDisplayWidget(projectId: widget.projectId),
                    _Gap(),
                    DebugSectionWidget(projectId: widget.projectId),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: RColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: RColors.accent,
          secondary: RColors.teal,
          surface: RColors.surface,
          error: RColors.error,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RColors.card,
          labelStyle:
              const TextStyle(color: RColors.textSecondary, fontSize: 13),
          hintStyle:
              TextStyle(color: RColors.textSecondary.withOpacity(0.5)),
          helperStyle:
              const TextStyle(color: RColors.textSecondary, fontSize: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: RColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: RColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: RColors.card,
          contentTextStyle:
              const TextStyle(color: RColors.textPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              color: RColors.textPrimary, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(
              color: RColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: RColors.textPrimary, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(
              color: RColors.textSecondary, fontSize: 12),
          bodyLarge: TextStyle(color: RColors.textPrimary),
          bodyMedium:
              TextStyle(color: RColors.textSecondary, fontSize: 13),
          bodySmall:
              TextStyle(color: RColors.textSecondary, fontSize: 11),
        ),
      );
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
        // Background gradient — indigo + purple blend
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0F14),
                RColors.accentSoft.withOpacity(0.28),
                RColors.purpleSoft.withOpacity(0.18),
              ],
            ),
          ),
        ),
        // Animated waves
        AnimatedBuilder(
          animation: waveController,
          builder: (_, __) => CustomPaint(
            painter: _AskWavePainter(
              progress: waveController.value,
              color1: RColors.accent.withOpacity(0.18),
              color2: RColors.purple.withOpacity(0.12),
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
                  _HeroBadge(
                      label: 'SEARCH', color: RColors.purple),
                  const SizedBox(width: 8),
                  _HeroBadge(
                      label: 'ASK AI', color: RColors.accent),
                  const SizedBox(width: 8),
                  _HeroBadge(
                      label: 'PROJECT $projectId',
                      color: RColors.textSecondary),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Search & ask across\nyour knowledge',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: RColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Semantic search · RAG answers · debug traces',
                style: TextStyle(
                  fontSize: 13,
                  color: RColors.textPrimary.withOpacity(0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
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
    wave(color1.withOpacity(0.5), 9, 1.1, 0.5);
    wave(color2, 19, 0.45, 0.9);
    wave(color2.withOpacity(0.4), 7, 1.3, 1.4);
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
                color: leftColor.withOpacity(0.2), thickness: 1)),
        const SizedBox(width: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: RColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: leftColor)),
              const SizedBox(width: 5),
              Text(leftLabel,
                  style: TextStyle(
                      color: leftColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·',
                    style: TextStyle(
                        color: RColors.textSecondary
                            .withOpacity(0.4))),
              ),
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: rightColor)),
              const SizedBox(width: 5),
              Text(rightLabel,
                  style: TextStyle(
                      color: rightColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Divider(
                color: rightColor.withOpacity(0.2), thickness: 1)),
      ],
    );
  }
}

// ── Gap helper ───────────────────────────────────────────────────────────────
class _Gap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(height: 14);
}