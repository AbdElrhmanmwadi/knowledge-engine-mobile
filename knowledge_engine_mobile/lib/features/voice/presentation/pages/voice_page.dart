import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/voice_provider.dart';
import '../widgets/recording_card.dart';
import '../widgets/hero_header.dart';
import '../widgets/action_tile.dart';
import '../widgets/playback_bar.dart';
import '../widgets/output_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/section_label.dart';

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
    final state = ref.watch(voiceStateProvider(widget.projectId));
    final notifier = ref.read(voiceNotifierProvider(widget.projectId).notifier);
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final accent = AppTheme.accentColor;
    final teal = AppTheme.voiceColor;
    final accentSoft = accent.withOpacity(0.08);
    final card = AppTheme.surfaceColor;
    final textPrimary = AppTheme.textPrimary;
    final textSecondary = AppTheme.textSecondary;
    final error = AppTheme.errorColor;
    final warning = AppTheme.warningColor;

    return Scaffold(
      backgroundColor: bg,
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────
            SliverAppBar(
              backgroundColor: bg,
              expandedHeight: 220.h,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: HeroHeader(
                  projectId: widget.projectId,
                  isRecording: state.isRecording,
                  isBusy: state.isBusy,
                  waveController: _waveController,
                  pulseController: _pulseController,
                  accent: accent,
                  teal: teal,
                  accentSoft: accentSoft,
                ),
              ),
              title: Text(
                'Voice Studio',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: textPrimary,
                ),
              ),
              centerTitle: false,
            ),

            // ── Body ─────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Alerts ───────────────────────────────
                  if (state.micPermissionDenied) ...[
                    AlertBanner(
                      icon: Icons.mic_off_rounded,
                      color: warning,
                      message:
                          'Microphone access is off. Enable it in system settings.',
                    ),
                    SizedBox(height: 12.h),
                  ],
                  if (state.actionError != null) ...[
                    AlertBanner(
                      icon: Icons.error_outline_rounded,
                      color: error,
                      message: state.actionError!,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // ── Recording controls ───────────────────
                  SectionLabel(label: 'Audio Source'),
                  SizedBox(height: 12.h),
                  RecordingCard(
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

                  SizedBox(height: 24.h),

                  // ── Settings ─────────────────────────────
                  SectionLabel(label: 'Settings'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _languageController,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Language',
                            hintText: 'e.g. en',
                            prefixIcon: Icon(
                              Icons.language_rounded,
                              size: 18.r,
                              color: textSecondary,
                            ),
                          ),
                          onChanged: notifier.updateLanguage,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _limitController,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14.sp,
                          ),
                          decoration: InputDecoration(
                            labelText: 'RAG limit',
                            prefixIcon: Icon(
                              Icons.manage_search_rounded,
                              size: 18.r,
                              color: textSecondary,
                            ),
                            errorText: state.voiceChatLimitError,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: notifier.updateVoiceChatLimit,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // ── Actions ──────────────────────────────
                  SectionLabel(label: 'Actions'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: ActionTile(
                          icon: Icons.transcribe_rounded,
                          label: 'Speech\nto Text',
                          color: accent,
                          disabled: state.isBusy || !state.hasAudioFile,
                          onTap: () => notifier.runSpeechToText(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ActionTile(
                          icon: Icons.forum_rounded,
                          label: 'Voice\nChat',
                          color: teal,
                          disabled: state.isBusy || !state.hasAudioFile,
                          onTap: () => notifier.runVoiceChat(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // ── TTS ──────────────────────────────────
                  SectionLabel(label: 'Text to Speech'),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _ttsController,
                    minLines: 3,
                    maxLines: 6,
                    style: TextStyle(color: textPrimary, fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: 'Enter text to synthesize…',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60.h),
                        child: Icon(
                          Icons.text_fields_rounded,
                          size: 18.r,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    onChanged: notifier.updateTtsText,
                  ),
                  SizedBox(height: 12.h),
                  PlaybackBar(
                    state: state,
                    notifier: notifier,
                    accent: accent,
                    teal: teal,
                    card: card,
                    textSecondary: textSecondary,
                  ),

                  SizedBox(height: 28.h),

                  // ── Transcript ───────────────────────────
                  OutputCard(
                    label: 'Transcript',
                    icon: Icons.article_outlined,
                    content: state.transcript,
                    accentColor: accent,
                    card: card,
                    textSecondary: textSecondary,
                  ),

                  SizedBox(height: 16.h),

                  // ── Answer ───────────────────────────────
                  OutputCard(
                    label: 'Answer',
                    icon: Icons.auto_awesome_rounded,
                    content: state.answer,
                    accentColor: teal,
                    card: card,
                    textSecondary: textSecondary,
                  ),

                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
