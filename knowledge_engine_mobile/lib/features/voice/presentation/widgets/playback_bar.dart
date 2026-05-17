import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.record_voice_over_rounded, size: 16),
              label: const Text('Synthesize'),
            ),
          ),
          const SizedBox(width: 10),
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
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              textStyle: const TextStyle(fontSize: 13),
            ),
            icon: Icon(
              state.isPlayingAudio
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline_rounded,
              size: 18,
            ),
            label: Text(state.isPlayingAudio ? 'Stop' : 'Play'),
          ),
          const SizedBox(width: 8),
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
                size: 20,
              ),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
