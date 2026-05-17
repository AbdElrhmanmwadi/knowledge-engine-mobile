import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../providers/voice_provider.dart';

class RecordingCard extends StatelessWidget {
  const RecordingCard({
    Key? key,
    required this.state,
    required this.notifier,
    required this.isRecording,
    required this.pulseController,
    required this.accent,
    required this.error,
    required this.teal,
    required this.card,
    required this.textSecondary,
  }) : super(key: key);

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecording
              ? error.withOpacity(0.4)
              : Colors.white.withOpacity(0.07),
          width: isRecording ? 1.5 : 1,
        ),
        boxShadow: isRecording
            ? [
                BoxShadow(
                  color: error.withOpacity(0.12),
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? error.withOpacity(0.15 + 0.1 * pulseController.value)
                        : error.withOpacity(0.12),
                    border: Border.all(
                      color: isRecording
                          ? error.withOpacity(0.6 + 0.4 * pulseController.value)
                          : error.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: error,
                      size: 24,
                    ),
                    onPressed: state.isBusy
                        ? null
                        : isRecording
                        ? () => notifier.stopRecording()
                        : () => notifier.startRecording(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecording ? 'Recording…' : 'Tap to record',
                      style: TextStyle(
                        color: isRecording ? error : const Color(0xFFF0F2FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRecording
                          ? 'Press stop when done'
                          : 'Or pick an audio file below',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pick file button
          OutlinedButton.icon(
            onPressed: state.isBusy ? null : () => notifier.pickAudioFile(),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.audio_file_outlined, size: 16),
            label: const Text('Pick audio file'),
          ),
          if (state.selectedAudioPath != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: teal, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      p.basename(state.selectedAudioPath!),
                      style: TextStyle(
                        color: teal,
                        fontSize: 12,
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
