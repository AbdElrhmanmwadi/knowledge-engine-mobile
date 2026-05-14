import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/voice_provider.dart';

/// Voice features: STT, TTS, and RAG voice chat for the current project.
class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  late final TextEditingController _languageController;
  late final TextEditingController _limitController;
  late final TextEditingController _ttsController;

  @override
  void initState() {
    super.initState();
    _languageController = TextEditingController();
    _limitController = TextEditingController(text: '30');
    _ttsController = TextEditingController();
  }

  @override
  void dispose() {
    _languageController.dispose();
    _limitController.dispose();
    _ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    final state = ref.watch(voiceStateProvider(projectId));
    final notifier = ref.read(voiceNotifierProvider(projectId).notifier);

    ref.listen<VoiceState>(voiceStateProvider(projectId), (prev, next) {
      if (prev?.language != next.language &&
          _languageController.text != next.language) {
        _languageController.text = next.language;
        _languageController.selection = TextSelection.collapsed(
          offset: _languageController.text.length,
        );
      }
      if (prev?.voiceChatLimit != next.voiceChatLimit) {
        final nextText = next.voiceChatLimit.toString();
        if (_limitController.text != nextText) {
          _limitController.text = nextText;
        }
      }
      if (prev?.ttsText != next.ttsText &&
          _ttsController.text != next.ttsText) {
        _ttsController.text = next.ttsText;
        _ttsController.selection = TextSelection.collapsed(
          offset: _ttsController.text.length,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice'),
        centerTitle: false,
      ),
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        AppTheme.voiceColor,
                        AppTheme.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speak with your knowledge',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project $projectId — transcribe recordings, hear answers read aloud, or ask a question by voice.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (state.micPermissionDenied)
                  Card(
                    color: AppTheme.warningColor.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.mic_off, color: AppTheme.warningColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Microphone access is off. Enable it in system settings to record.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state.actionError != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: AppTheme.errorColor.withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: AppTheme.errorColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.actionError!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Audio',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => notifier.startRecording(),
                      icon: const Icon(Icons.fiber_manual_record),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      label: const Text('Record'),
                    ),
                    FilledButton.icon(
                      onPressed: (!state.isRecording || state.isBusy)
                          ? null
                          : () => notifier.stopRecording(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => notifier.pickAudioFile(),
                      icon: const Icon(Icons.audio_file_outlined),
                      label: const Text('Pick file'),
                    ),
                  ],
                ),
                if (state.selectedAudioPath != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${p.basename(state.selectedAudioPath!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _languageController,
                  decoration: const InputDecoration(
                    labelText: 'Language (optional)',
                    hintText: 'e.g. en',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateLanguage,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _limitController,
                  decoration: InputDecoration(
                    labelText: 'Voice chat retrieval limit',
                    border: const OutlineInputBorder(),
                    errorText: state.voiceChatLimitError,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: notifier.updateVoiceChatLimit,
                ),
                const SizedBox(height: 16),
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: (state.isBusy || !state.hasAudioFile)
                          ? null
                          : () => notifier.runSpeechToText(),
                      child: const Text('Speech to text'),
                    ),
                    FilledButton(
                      onPressed: (state.isBusy || !state.hasAudioFile)
                          ? null
                          : () => notifier.runVoiceChat(),
                      child: const Text('Voice chat'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ttsController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Text for TTS',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateTtsText,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton(
                      onPressed: state.isBusy
                          ? null
                          : () => notifier.runTextToSpeech(),
                      child: const Text('Text to speech'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: state.isPlayingAudio
                          ? () => notifier.stopPlayback()
                          : (state.isBusy
                              ? null
                              : () => notifier.playLastTtsOrVoiceReply()),
                      child: Text(
                        state.isPlayingAudio ? 'Stop playback' : 'Play audio',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: state.isBusy
                        ? null
                        : () => notifier.playVoiceChatReplyOnly(),
                    child: const Text('Play last voice-chat reply only'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Transcript',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      state.transcript.isEmpty
                          ? '—'
                          : state.transcript,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Answer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      state.answer.isEmpty ? '—' : state.answer,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
