import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A self-contained animated wave background used across the app's pages
/// (Files, Projects, Dashboard, Ask, Translate heroes plus Onboarding, Auth
/// and the Agent chat empty state).
///
/// It owns its own [AnimationController], so callers only need to drop it into
/// a [Stack] and supply the stroke colors. Place it behind your content; it
/// paints layered sine waves that drift horizontally.
///
/// Typical usage inside a hero (fills the parent via [StackFit.expand]):
/// ```dart
/// Stack(
///   fit: StackFit.expand,
///   children: [
///     gradient,
///     AnimatedWaves(color1: ..., color2: ...),
///     content,
///   ],
/// )
/// ```
/// Or anchored to the bottom of a full screen:
/// ```dart
/// Positioned(
///   left: 0, right: 0, bottom: 0, height: 220.h,
///   child: AnimatedWaves(color1: ..., color2: ...),
/// )
/// ```
class AnimatedWaves extends StatefulWidget {
  const AnimatedWaves({
    super.key,
    required this.color1,
    required this.color2,
    this.duration = const Duration(seconds: 3),
  });

  /// Primary stroke color (two layers are drawn from it).
  final Color color1;

  /// Secondary stroke color (two layers are drawn from it).
  final Color color2;

  /// How long one full animation cycle takes.
  final Duration duration;

  @override
  State<AnimatedWaves> createState() => _AnimatedWavesState();
}

class _AnimatedWavesState extends State<AnimatedWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        size: Size.infinite,
        painter: WavePainter(
          progress: _controller.value,
          color1: widget.color1,
          color2: widget.color2,
        ),
      ),
    );
  }
}

/// Paints four layered horizontal sine waves. Exposed for callers that already
/// manage their own [AnimationController]; most pages should use
/// [AnimatedWaves] instead.
class WavePainter extends CustomPainter {
  const WavePainter({
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
  bool shouldRepaint(WavePainter old) => old.progress != progress;
}
