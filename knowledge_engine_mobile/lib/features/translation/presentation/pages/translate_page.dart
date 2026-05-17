import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/translation_provider.dart';
import '../widgets/job_creation_section.dart';
import '../widgets/job_status_section.dart';

// ── Shared design tokens (mirror voice_page.dart) ──────────────────────────
class TColors {
  static const bg      = Color(0xFF0D0F14);
  static const surface = Color(0xFF161923);
  static const card    = Color(0xFF1E2230);
  static const accent  = Color(0xFF6C8EFF); // indigo – same as voice
  static const amber   = Color(0xFFFFB547); // translate feature colour
  static const amberSoft = Color(0xFFE08A00);
  static const teal    = Color(0xFF38EFC4);
  static const textPrimary   = Color(0xFFF0F2FF);
  static const textSecondary = Color(0xFF8891B0);
  static const error   = Color(0xFFFF5C6B);

  
}

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

    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        backgroundColor: TColors.bg,
        body: LoadingOverlay(
          isLoading: state.isBusy,
          message: state.activeLoadingMessage,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: TColors.bg,
                expandedHeight: 210,
                pinned: true,
                elevation: 0,
                title: const Text(
                  'File Translation',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: TColors.textPrimary,
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
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: TColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: TColors.amber,
          secondary: TColors.teal,
          surface: TColors.surface,
          error: TColors.error,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TColors.card,
          labelStyle: const TextStyle(color: TColors.textSecondary, fontSize: 13),
          hintStyle: TextStyle(color: TColors.textSecondary.withOpacity(0.5)),
          helperStyle: const TextStyle(color: TColors.textSecondary, fontSize: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.amber, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: TColors.textPrimary,
          iconColor: TColors.textSecondary,
          collapsedTextColor: TColors.textSecondary,
          collapsedIconColor: TColors.textSecondary,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? TColors.amber : TColors.textSecondary,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? TColors.amber.withOpacity(0.35)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: TColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
        ),
        dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.06)),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: TColors.textPrimary, fontWeight: FontWeight.w700),
          titleLarge:  TextStyle(color: TColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: TColors.textPrimary, fontWeight: FontWeight.w600),
          titleSmall:  TextStyle(color: TColors.textSecondary, fontSize: 12),
          bodyLarge:   TextStyle(color: TColors.textPrimary),
          bodyMedium:  TextStyle(color: TColors.textSecondary, fontSize: 13),
          bodySmall:   TextStyle(color: TColors.textSecondary, fontSize: 11),
        ),
      );
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
                const Color(0xFF0D0F14),
                TColors.amberSoft.withOpacity(0.3),
                TColors.teal.withOpacity(0.08),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
          builder: (_, __) => CustomPaint(
            painter: _TranslateWavePainter(
              progress: waveController.value,
              color1: TColors.amber.withOpacity(0.18),
              color2: TColors.teal.withOpacity(0.1),
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
                  color: TColors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TColors.amber.withOpacity(0.35)),
                ),
                child: Text(
                  'PROJECT $projectId',
                  style: const TextStyle(
                    color: TColors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Translate project\nfiles',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create jobs · track progress · download results',
                style: TextStyle(
                  fontSize: 13,
                  color: TColors.textPrimary.withOpacity(0.5),
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