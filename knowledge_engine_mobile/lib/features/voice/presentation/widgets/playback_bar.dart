import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/voice_provider.dart';
import '../../../../l10n/l10n.dart';

class PlaybackBar extends StatelessWidget {
  const PlaybackBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.accent,
    required this.teal,
    required this.card,
    required this.textSecondary,
  });

  final VoiceState state;
  final dynamic notifier;
  final Color accent;
  final Color teal;
  final Color card;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          // TTS generate
          Expanded(
            child: FilledButton.icon(
              onPressed: state.isBusy ? null : () => notifier.runTextToSpeech(),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Icon(Icons.record_voice_over_rounded, size: 16.r),
              label: Text(context.l10n.synthesize),
            ),
          ),
          SizedBox(width: 10.w),
          // Play/Stop
          OutlinedButton.icon(
            onPressed: state.isPlayingAudio
                ? () => notifier.stopPlayback()
                : (state.isBusy
                      ? null
                      : () => notifier.playLastTtsOrVoiceReply()),
            style: OutlinedButton.styleFrom(
              foregroundColor: teal,
              side: BorderSide(color: teal.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
              textStyle: TextStyle(fontSize: 13.sp),
            ),
            icon: Icon(
              state.isPlayingAudio
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline_rounded,
              size: 18.r,
            ),
            label: Text(state.isPlayingAudio ? context.l10n.stop : context.l10n.play),
          ),
          SizedBox(width: 8.w),
          // Voice reply only
          Tooltip(
            message: context.l10n.playLastVoiceReplyTooltip,
            child: IconButton(
              onPressed: state.isBusy
                  ? null
                  : () => notifier.playVoiceChatReplyOnly(),
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: textSecondary,
                size: 20.r,
              ),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
