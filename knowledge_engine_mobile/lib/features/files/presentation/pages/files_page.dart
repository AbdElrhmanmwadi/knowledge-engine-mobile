import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_overlay.dart';
import '../providers/files_provider.dart';
import '../widgets/index_section.dart';
import '../widgets/process_section.dart';
import '../widgets/status_log_widget.dart';
import '../widgets/upload_section.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
class FColors {
  static const bg            = Color(0xFF0D0F14);
  static const surface       = Color(0xFF161923);
  static const card          = Color(0xFF1E2230);
  static const accent        = Color(0xFF38EFC4); // teal — documents/files
  static const accentSoft    = Color(0xFF0F6E56);
  static const indigo        = Color(0xFF6C8EFF);
  static const error         = Color(0xFFFF5C6B);
  static const warning       = Color(0xFFFFB547);
  static const textPrimary   = Color(0xFFF0F2FF);
  static const textSecondary = Color(0xFF8891B0);
}

/// Files Page — Upload → Prepare → Index workflow.
class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({Key? key, required this.projectId}) : super(key: key);
  final int projectId;

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage>
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
    final state = ref.watch(filesStateProvider(widget.projectId));

    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        backgroundColor: FColors.bg,
        body: LoadingOverlay(
          isLoading: state.isBusy,
          message: state.activeLoadingMessage,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: FColors.bg,
                expandedHeight: 210,
                pinned: true,
                elevation: 0,
                title: const Text(
                  'Documents',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: FColors.textPrimary,
                  ),
                ),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _FilesHero(
                    projectId: widget.projectId,
                    waveController: _waveController,
                    currentStep: _currentStep(state),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Error banner
                    if (state.errorMessage != null) ...[
                      _AlertBanner(
                        icon: Icons.error_outline_rounded,
                        color: FColors.error,
                        message: state.errorMessage!,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Step progress tracker
                    _StepTracker(state: state),
                    const SizedBox(height: 20),

                    // Sections
                    UploadSection(projectId: widget.projectId),
                    const SizedBox(height: 14),
                    ProcessSection(projectId: widget.projectId),
                    const SizedBox(height: 14),
                    IndexSection(projectId: widget.projectId),
                    const SizedBox(height: 14),
                    StatusLogWidget(projectId: widget.projectId),
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

  int _currentStep(dynamic state) {
    if (state.indexResponse != null) return 3;
    if (state.processResponse != null) return 2;
    if (state.fileId != null) return 1;
    return 0;
  }

  ThemeData _buildTheme() => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: FColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: FColors.accent,
          secondary: FColors.indigo,
          surface: FColors.surface,
          error: FColors.error,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: FColors.card,
          labelStyle: const TextStyle(
              color: FColors.textSecondary, fontSize: 13),
          hintStyle:
              TextStyle(color: FColors.textSecondary.withOpacity(0.5)),
          helperStyle: const TextStyle(
              color: FColors.textSecondary, fontSize: 11),
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
                const BorderSide(color: FColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: FColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? FColors.accent
                  : Colors.transparent),
          checkColor: WidgetStateProperty.all(FColors.bg),
          side: BorderSide(color: FColors.textSecondary.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: FColors.textPrimary,
          iconColor: FColors.textSecondary,
          collapsedTextColor: FColors.textSecondary,
          collapsedIconColor: FColors.textSecondary,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: FColors.card,
          contentTextStyle:
              const TextStyle(color: FColors.textPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: FColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: FColors.textPrimary, fontWeight: FontWeight.w600),
          titleSmall:
              TextStyle(color: FColors.textSecondary, fontSize: 12),
          bodyLarge: TextStyle(color: FColors.textPrimary),
          bodyMedium:
              TextStyle(color: FColors.textSecondary, fontSize: 13),
          bodySmall:
              TextStyle(color: FColors.textSecondary, fontSize: 11),
        ),
      );
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _FilesHero extends StatelessWidget {
  const _FilesHero({
    required this.projectId,
    required this.waveController,
    required this.currentStep,
  });

  final int projectId;
  final AnimationController waveController;
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
                const Color(0xFF0D0F14),
                FColors.accentSoft.withOpacity(0.35),
                FColors.indigo.withOpacity(0.1),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: waveController,
          builder: (_, __) => CustomPaint(
            painter: _WavePainter(
              progress: waveController.value,
              color1: FColors.accent.withOpacity(0.16),
              color2: FColors.indigo.withOpacity(0.1),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FColors.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: FColors.accent.withOpacity(0.32)),
                    ),
                    child: Text(
                      'PROJECT $projectId',
                      style: const TextStyle(
                        color: FColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (currentStep == 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: FColors.accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: FColors.accent.withOpacity(0.32)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              color: FColors.accent, size: 11),
                          SizedBox(width: 4),
                          Text(
                            'READY',
                            style: TextStyle(
                              color: FColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Add your\ndocuments',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: FColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload · prepare · index into knowledge base',
                style: TextStyle(
                  fontSize: 13,
                  color: FColors.textPrimary.withOpacity(0.5),
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
    void wave(Color c, double amp, double speed, double off) {
      final p = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      final phase = (progress * speed + off) * 2 * math.pi;
      path.moveTo(0, size.height * 0.6);
      for (double x = 0; x <= size.width; x++) {
        path.lineTo(
            x,
            size.height * 0.6 +
                math.sin(x / size.width * 3 * math.pi + phase) * amp);
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

// ── Step progress tracker ────────────────────────────────────────────────────
class _StepTracker extends StatelessWidget {
  const _StepTracker({required this.state});
  final dynamic state;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(label: 'Upload', icon: Icons.upload_file_rounded),
      _StepData(label: 'Prepare', icon: Icons.auto_awesome_motion_outlined),
      _StepData(label: 'Index', icon: Icons.publish_rounded),
    ];

    final current = state.indexResponse != null
        ? 3
        : state.processResponse != null
            ? 2
            : state.fileId != null
                ? 1
                : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
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
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        i < current
                            ? FColors.accent
                            : FColors.textSecondary.withOpacity(0.2),
                        (i + 1) <= current
                            ? FColors.accent
                            : FColors.textSecondary.withOpacity(0.2),
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

    final Color dotColor = done
        ? FColors.accent
        : active
            ? FColors.accent
            : FColors.textSecondary.withOpacity(0.3);

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active
                ? FColors.accent.withOpacity(0.12)
                : Colors.white.withOpacity(0.04),
            border: Border.all(
              color: dotColor,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Icon(
            done ? Icons.check_rounded : data.icon,
            size: 16,
            color: dotColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: TextStyle(
            color: pending
                ? FColors.textSecondary.withOpacity(0.4)
                : active
                    ? FColors.accent
                    : FColors.textSecondary,
            fontSize: 11,
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
                style:
                    TextStyle(color: color, fontSize: 12, height: 1.45)),
          ),
        ],
      ),
    );
  }
}