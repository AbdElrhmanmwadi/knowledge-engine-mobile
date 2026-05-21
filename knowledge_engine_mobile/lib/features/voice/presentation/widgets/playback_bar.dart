import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/voice_provider.dart';

class PlaybackBar extends StatelessWidget {
  const PlaybackBar({
    Key? key,
    required this.state,
    required this.notifier,
    required this.accent,
    required this.teal,
    required this.card,
    required this.textSecondary,
  }) : super(key: key);

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
        border: Border.all(color: Colors.white.withOpacity(0.07)),
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
              label: const Text('Synthesize'),
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
              side: BorderSide(color: teal.withOpacity(0.45)),
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
            label: Text(state.isPlayingAudio ? 'Stop' : 'Play'),
          ),
          SizedBox(width: 8.w),
          // Voice reply only
          Tooltip(
            message: 'Play last voice-chat reply only',
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
