import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/voice_provider.dart';

// ─────────────────────────────────────────────
//  VoicePage
// ─────────────────────────────────────────────
class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage>
    with TickerProviderStateMixin {
  late final TextEditingController _languageController;
  late final TextEditingController _limitController;
  late final TextEditingController _ttsController;

  // Waveform animation
  late final AnimationController _waveController;
  // Mic pulse animation
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _languageController = TextEditingController();
    _limitController = TextEditingController(text: '30');
    _ttsController = TextEditingController();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _languageController.dispose();
    _limitController.dispose();
    _ttsController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
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
        _languageController.selection =
            TextSelection.collapsed(offset: _languageController.text.length);
      }
      if (prev?.voiceChatLimit != next.voiceChatLimit) {
        final t = next.voiceChatLimit.toString();
        if (_limitController.text != t) _limitController.text = t;
      }
      if (prev?.ttsText != next.ttsText &&
          _ttsController.text != next.ttsText) {
        _ttsController.text = next.ttsText;
        _ttsController.selection =
            TextSelection.collapsed(offset: _ttsController.text.length);
      }
    });

    const bg = Color(0xFF0D0F14);
    const surface = Color(0xFF161923);
    const card = Color(0xFF1E2230);
    const accent = Color(0xFF6C8EFF);
    const accentSoft = Color(0xFF3D5AF1);
    const teal = Color(0xFF38EFC4);
    const textPrimary = Color(0xFFF0F2FF);
    const textSecondary = Color(0xFF8891B0);
    const error = Color(0xFFFF5C6B);
    const warning = Color(0xFFFFB547);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: teal,
          surface: surface,
          error: error,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
          hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      child: Scaffold(
        // backgroundColor: bg,
        body: LoadingOverlay(
          isLoading: state.isBusy,
          message: state.activeLoadingMessage,
          child: CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────
              SliverAppBar(
                backgroundColor: bg,
                expandedHeight: 220,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _HeroHeader(
                    projectId: projectId,
                    isRecording: state.isRecording,
                    isBusy: state.isBusy,
                    waveController: _waveController,
                    pulseController: _pulseController,
                    accent: accent,
                    teal: teal,
                    accentSoft: accentSoft,
                  ),
                ),
                title: const Text(
                  'Voice Studio',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: textPrimary,
                  ),
                ),
                centerTitle: false,
              ),

              // ── Body ─────────────────────────────────────────
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Alerts ───────────────────────────────
                    if (state.micPermissionDenied) ...[
                      _AlertBanner(
                        icon: Icons.mic_off_rounded,
                        color: warning,
                        message:
                            'Microphone access is off. Enable it in system settings.',
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (state.actionError != null) ...[
                      _AlertBanner(
                        icon: Icons.error_outline_rounded,
                        color: error,
                        message: state.actionError!,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Recording controls ───────────────────
                    _SectionLabel(label: 'Audio Source'),
                    const SizedBox(height: 12),
                    _RecordingCard(
                      state: state,
                      notifier: notifier,
                      isRecording: state.isRecording,
                      pulseController: _pulseController,
                      accent: accent,
                      error: error,
                      teal: teal,
                      card: card,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 24),

                    // ── Settings ─────────────────────────────
                    _SectionLabel(label: 'Settings'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _languageController,
                            style: const TextStyle(
                                color: textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'Language',
                              hintText: 'e.g. en',
                              prefixIcon: Icon(Icons.language_rounded,
                                  size: 18, color: textSecondary),
                            ),
                            onChanged: notifier.updateLanguage,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _limitController,
                            style: const TextStyle(
                                color: textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'RAG limit',
                              prefixIcon: const Icon(
                                  Icons.manage_search_rounded,
                                  size: 18,
                                  color: textSecondary),
                              errorText: state.voiceChatLimitError,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: notifier.updateVoiceChatLimit,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Actions ──────────────────────────────
                    _SectionLabel(label: 'Actions'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.transcribe_rounded,
                            label: 'Speech\nto Text',
                            color: accent,
                            disabled: state.isBusy || !state.hasAudioFile,
                            onTap: () => notifier.runSpeechToText(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.forum_rounded,
                            label: 'Voice\nChat',
                            color: teal,
                            disabled: state.isBusy || !state.hasAudioFile,
                            onTap: () => notifier.runVoiceChat(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── TTS ──────────────────────────────────
                    _SectionLabel(label: 'Text to Speech'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ttsController,
                      minLines: 3,
                      maxLines: 6,
                      style: const TextStyle(color: textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Enter text to synthesize…',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.text_fields_rounded,
                              size: 18, color: textSecondary),
                        ),
                      ),
                      onChanged: notifier.updateTtsText,
                    ),
                    const SizedBox(height: 12),
                    _PlaybackBar(
                      state: state,
                      notifier: notifier,
                      accent: accent,
                      teal: teal,
                      card: card,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 28),

                    // ── Transcript ───────────────────────────
                    _OutputCard(
                      label: 'Transcript',
                      icon: Icons.article_outlined,
                      content: state.transcript,
                      accentColor: accent,
                      card: card,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 16),

                    // ── Answer ───────────────────────────────
                    _OutputCard(
                      label: 'Answer',
                      icon: Icons.auto_awesome_rounded,
                      content: state.answer,
                      accentColor: teal,
                      card: card,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hero Header with animated waveform
// ─────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.projectId,
    required this.isRecording,
    required this.isBusy,
    required this.waveController,
    required this.pulseController,
    required this.accent,
    required this.teal,
    required this.accentSoft,
  });

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
            painter: _WavePainter(
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
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: accent.withOpacity(0.35), width: 1),
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
                          color: const Color(0xFFFF5C6B).withOpacity(
                              0.5 + 0.5 * pulseController.value),
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

// ─────────────────────────────────────────────
//  Wave painter
// ─────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  _WavePainter({
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
        final y = size.height * 0.6 +
            math.sin(x / size.width * 3 * math.pi + phase) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    drawWave(color1, 18, 0.7, 0);
    drawWave(color1.withOpacity(0.5), 12, 1.1, 0.4);
    drawWave(color2, 22, 0.5, 0.8);
    drawWave(color2.withOpacity(0.4), 8, 1.4, 1.2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Recording card
// ─────────────────────────────────────────────
class _RecordingCard extends StatelessWidget {
  const _RecordingCard({
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
                )
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
                      style:
                          TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pick file button
          OutlinedButton.icon(
            onPressed:
                state.isBusy ? null : () => notifier.pickAudioFile(),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.audio_file_outlined, size: 16),
            label: const Text('Pick audio file'),
          ),
          if (state.selectedAudioPath != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: teal, size: 14),
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

// ─────────────────────────────────────────────
//  Action tile
// ─────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.disabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.38 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Playback bar
// ─────────────────────────────────────────────
class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({
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
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
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
                  borderRadius: BorderRadius.circular(10)),
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
              icon: Icon(Icons.chat_bubble_outline_rounded,
                  color: textSecondary, size: 20),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Output card
// ─────────────────────────────────────────────
class _OutputCard extends StatelessWidget {
  const _OutputCard({
    required this.label,
    required this.icon,
    required this.content,
    required this.accentColor,
    required this.card,
    required this.textSecondary,
  });

  final String label;
  final IconData icon;
  final String content;
  final Color accentColor;
  final Color card;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isEmpty = content.isEmpty;
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty
              ? Colors.white.withOpacity(0.07)
              : accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                if (!isEmpty) ...[
                  const Spacer(),
                  Text(
                    '${content.length} chars',
                    style:
                        TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText(
              isEmpty ? 'No output yet…' : content,
              style: TextStyle(
                color: isEmpty
                    ? textSecondary.withOpacity(0.5)
                    : const Color(0xFFF0F2FF),
                fontSize: 14,
                height: 1.6,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Alert banner
// ─────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF8891B0),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}