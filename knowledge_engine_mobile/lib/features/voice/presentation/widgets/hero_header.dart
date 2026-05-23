import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                accentSoft.withValues(alpha: 0.35),
                teal.withValues(alpha: 0.12),
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
              color1: accent.withValues(alpha: isRecording ? 0.45 : 0.18),
              color2: teal.withValues(alpha: isRecording ? 0.3 : 0.1),
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
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PROJECT $projectId',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (isRecording) ...[
                    SizedBox(width: 10.w),
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, __) => Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFF5C6B,
                          ).withValues(alpha: 0.5 + 0.5 * pulseController.value),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                     Text(
                      'REC',
                      style: TextStyle(
                        color: Color(0xFFFF5C6B),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 10.h),
               Text(
                'Speak with your\nknowledge',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0F2FF),
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Transcribe recordings · voice chat · hear answers',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFFF0F2FF).withValues(alpha: 0.55),
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
