import 'package:flutter/material.dart';

import 'wave_painter.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    Key? key,
    required this.projectId,
    required this.isRecording,
    required this.isBusy,
    required this.waveController,
    required this.pulseController,
    required this.accent,
    required this.teal,
    required this.accentSoft,
  }) : super(key: key);

  final int projectId;
  final bool isRecording;
  final bool isBusy;
  final AnimationController waveController;
  final AnimationController pulseController;
  final Color accent;
  final Color teal;
  final Color accentSoft;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0F14),
                accentSoft.withOpacity(0.35),
                teal.withOpacity(0.12),
              ],
            ),
          ),
        ),
        // Animated waveform
        AnimatedBuilder(
          animation: waveController,
          builder: (_, __) => CustomPaint(
            painter: WavePainter(
              progress: waveController.value,
              color1: accent.withOpacity(isRecording ? 0.45 : 0.18),
              color2: teal.withOpacity(isRecording ? 0.3 : 0.1),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PROJECT $projectId',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (isRecording) ...[
                    const SizedBox(width: 10),
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFF5C6B,
                          ).withOpacity(0.5 + 0.5 * pulseController.value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'REC',
                      style: TextStyle(
                        color: Color(0xFFFF5C6B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Speak with your\nknowledge',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0F2FF),
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Transcribe recordings · voice chat · hear answers',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFF0F2FF).withOpacity(0.55),
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
