import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  WavePainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  final double progress;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    void drawWave(Color color, double amplitude, double speed, double offset) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      final phase = (progress * speed + offset) * 2 * math.pi;
      path.moveTo(0, size.height * 0.6);
      for (double x = 0; x <= size.width; x++) {
        final y =
            size.height * 0.6 +
            math.sin(x / size.width * 3 * math.pi + phase) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    drawWave(color1, 18, 0.7, 0);
    drawWave(color1.withValues(alpha: 0.5), 12, 1.1, 0.4);
    drawWave(color2, 22, 0.5, 0.8);
    drawWave(color2.withValues(alpha: 0.4), 8, 1.4, 1.2);
  }

  @override
  bool shouldRepaint(WavePainter old) => old.progress != progress;
}
