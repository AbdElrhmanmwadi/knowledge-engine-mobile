import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;

import '../providers/voice_provider.dart';
import '../../../../l10n/l10n.dart';

class RecordingCard extends StatelessWidget {
  const RecordingCard({
    super.key,
    required this.state,
    required this.notifier,
    required this.isRecording,
    required this.pulseController,
    required this.accent,
    required this.error,
    required this.teal,
    required this.card,
    required this.textSecondary,
  });

  final VoiceState state;
  final dynamic notifier;
  final bool isRecording;
  final AnimationController pulseController;
  final Color accent;
  final Color error;
  final Color teal;
  final Color card;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isRecording
              ? error.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.07),
          width: isRecording ? 1.5 : 1,
        ),
        boxShadow: isRecording
            ? [
                BoxShadow(
                  color: error.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mic button
              AnimatedBuilder(
                animation: pulseController,
                builder: (_, child) => Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? error.withValues(alpha: 0.15 + 0.1 * pulseController.value)
                        : error.withValues(alpha: 0.12),
                    border: Border.all(
                      color: isRecording
                          ? error.withValues(alpha: 0.6 + 0.4 * pulseController.value)
                          : error.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: error,
                      size: 24.r,
                    ),
                    onPressed: state.isBusy
                        ? null
                        : isRecording
                        ? () => notifier.stopRecording()
                        : () => notifier.startRecording(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecording ? context.l10n.recording : context.l10n.tapToRecord,
                      style: TextStyle(
                        color: isRecording ? error : const Color(0xFFF0F2FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isRecording
                          ? context.l10n.pressStopWhenDone
                          : context.l10n.orPickAnAudioFileBelow,
                      style: TextStyle(color: textSecondary, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Pick file button
          OutlinedButton.icon(
            onPressed: state.isBusy ? null : () => notifier.pickAudioFile(),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              textStyle: TextStyle(fontSize: 13.sp),
            ),
            icon: Icon(Icons.audio_file_outlined, size: 16.r),
            label: Text(context.l10n.pickAudioFile),
          ),
          if (state.selectedAudioPath != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: teal, size: 14.r),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      p.basename(state.selectedAudioPath!),
                      style: TextStyle(
                        color: teal,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
