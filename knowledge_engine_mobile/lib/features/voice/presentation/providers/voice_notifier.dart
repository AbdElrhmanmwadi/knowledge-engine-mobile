import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/models/stt_response.dart';
import '../../../../core/models/tts_result.dart';
import '../../../../core/models/voice_chat_response.dart';
import '../../../../core/network/user_friendly_error.dart';
import '../../data/repositories/voice_repository.dart';

class VoiceState {
  const VoiceState({
    required this.currentProjectId,
    this.selectedAudioPath,
    this.isRecording = false,
    this.language = '',
    this.voiceChatLimit = 30,
    this.voiceChatLimitError,
    this.ttsText = '',
    this.transcript = '',
    this.answer = '',
    this.isSttLoading = false,
    this.isTtsLoading = false,
    this.isVoiceChatLoading = false,
    this.isPlayingAudio = false,
    this.actionError,
    this.micPermissionDenied = false,
    this.sttResponse,
    this.voiceChatResponse,
    this.lastTtsWavBytes,
  });

  factory VoiceState.initial(int projectId) {
    return VoiceState(currentProjectId: projectId);
  }

  final int currentProjectId;
  final String? selectedAudioPath;
  final bool isRecording;
  final String language;
  final int voiceChatLimit;
  final String? voiceChatLimitError;
  final String ttsText;
  final String transcript;
  final String answer;
  final bool isSttLoading;
  final bool isTtsLoading;
  final bool isVoiceChatLoading;
  final bool isPlayingAudio;
  final String? actionError;
  final bool micPermissionDenied;
  final SttResponse? sttResponse;
  final VoiceChatResponse? voiceChatResponse;
  final List<int>? lastTtsWavBytes;

  bool get isBusy =>
      isSttLoading || isTtsLoading || isVoiceChatLoading || isPlayingAudio;

  bool get hasAudioFile =>
      selectedAudioPath != null && selectedAudioPath!.trim().isNotEmpty;

  String? get activeLoadingMessage {
    if (isSttLoading) {
      return 'Transcribing audio...';
    }
    if (isTtsLoading) {
      return 'Generating speech...';
    }
    if (isVoiceChatLoading) {
      return 'Voice chat in progress...';
    }
    if (isPlayingAudio) {
      return 'Playing audio...';
    }
    return null;
  }

  static const Object _unset = Object();

  VoiceState copyWith({
    String? selectedAudioPath,
    bool? isRecording,
    String? language,
    int? voiceChatLimit,
    Object? voiceChatLimitError = _unset,
    String? ttsText,
    String? transcript,
    String? answer,
    bool? isSttLoading,
    bool? isTtsLoading,
    bool? isVoiceChatLoading,
    bool? isPlayingAudio,
    Object? actionError = _unset,
    bool? micPermissionDenied,
    Object? sttResponse = _unset,
    Object? voiceChatResponse = _unset,
    Object? lastTtsWavBytes = _unset,
  }) {
    return VoiceState(
      currentProjectId: currentProjectId,
      selectedAudioPath: selectedAudioPath ?? this.selectedAudioPath,
      isRecording: isRecording ?? this.isRecording,
      language: language ?? this.language,
      voiceChatLimit: voiceChatLimit ?? this.voiceChatLimit,
      voiceChatLimitError: identical(voiceChatLimitError, _unset)
          ? this.voiceChatLimitError
          : voiceChatLimitError as String?,
      ttsText: ttsText ?? this.ttsText,
      transcript: transcript ?? this.transcript,
      answer: answer ?? this.answer,
      isSttLoading: isSttLoading ?? this.isSttLoading,
      isTtsLoading: isTtsLoading ?? this.isTtsLoading,
      isVoiceChatLoading: isVoiceChatLoading ?? this.isVoiceChatLoading,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      actionError: identical(actionError, _unset)
          ? this.actionError
          : actionError as String?,
      micPermissionDenied: micPermissionDenied ?? this.micPermissionDenied,
      sttResponse: identical(sttResponse, _unset)
          ? this.sttResponse
          : sttResponse as SttResponse?,
      voiceChatResponse: identical(voiceChatResponse, _unset)
          ? this.voiceChatResponse
          : voiceChatResponse as VoiceChatResponse?,
      lastTtsWavBytes: identical(lastTtsWavBytes, _unset)
          ? this.lastTtsWavBytes
          : lastTtsWavBytes as List<int>?,
    );
  }
}

class VoiceNotifier extends AsyncNotifier<VoiceState> {
  VoiceNotifier(this._projectId);

  final int _projectId;
  late final VoiceRepository _repository;
  final AudioRecorder _recorder = AudioRecorder();
  AudioPlayer? _player;
  bool _isDisposed = false;

  @override
  VoiceState build() {
    _repository = VoiceRepository();
    ref.onDispose(() {
      _isDisposed = true;
      Future(() async {
        try {
          await _recorder.stop();
        } catch (_) {}
        try {
          await _recorder.dispose();
        } catch (_) {}
        try {
          await _player?.dispose();
        } catch (_) {}
      });
    });
    return VoiceState.initial(_projectId);
  }

  VoiceState get _currentState => state.maybeWhen(
        data: (value) => value,
        orElse: () => VoiceState.initial(_projectId),
      );

  void _updateState(VoiceState nextState) {
    if (_isDisposed) {
      return;
    }
    state = AsyncValue.data(nextState);
  }

  void updateLanguage(String value) {
    _updateState(_currentState.copyWith(language: value, actionError: null));
  }

  void updateTtsText(String value) {
    _updateState(_currentState.copyWith(ttsText: value, actionError: null));
  }

  void updateVoiceChatLimit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _updateState(_currentState.copyWith(
        voiceChatLimitError:
            'Limit must be between ${ValidationConstants.minVoiceChatLimit} and ${ValidationConstants.maxVoiceChatLimit}.',
      ));
      return;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null ||
        parsed < ValidationConstants.minVoiceChatLimit ||
        parsed > ValidationConstants.maxVoiceChatLimit) {
      _updateState(_currentState.copyWith(
        voiceChatLimitError:
            'Limit must be between ${ValidationConstants.minVoiceChatLimit} and ${ValidationConstants.maxVoiceChatLimit}.',
      ));
      return;
    }
    _updateState(_currentState.copyWith(
      voiceChatLimit: parsed,
      voiceChatLimitError: null,
    ));
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _updateState(_currentState.copyWith(micPermissionDenied: false));
      return true;
    }
    _updateState(_currentState.copyWith(
      micPermissionDenied: true,
      actionError: 'Microphone permission is required to record.',
    ));
    return false;
  }

  Future<void> startRecording() async {
    if (_currentState.isBusy) {
      return;
    }
    if (!await _ensureMicPermission()) {
      return;
    }
    if (!await _recorder.hasPermission()) {
      _updateState(_currentState.copyWith(
        actionError: 'Recording is not available on this device.',
      ));
      return;
    }
    final dir = await getTemporaryDirectory();
    final filePath = p.join(
      dir.path,
      'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      _updateState(_currentState.copyWith(
        isRecording: true,
        selectedAudioPath: filePath,
        actionError: null,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Could not start recording.',
        ),
      ));
    }
  }

  Future<void> stopRecording() async {
    if (!_currentState.isRecording) {
      return;
    }
    try {
      final path = await _recorder.stop();
      _updateState(_currentState.copyWith(
        isRecording: false,
        selectedAudioPath: path ?? _currentState.selectedAudioPath,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        isRecording: false,
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Could not stop recording.',
        ),
      ));
    }
  }

  Future<void> pickAudioFile() async {
    if (_currentState.isBusy) {
      return;
    }
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'wav',
        'mp3',
        'm4a',
        'aac',
        'ogg',
        'flac',
      ],
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      _updateState(_currentState.copyWith(
        actionError: 'Could not read the selected file path.',
      ));
      return;
    }
    _updateState(_currentState.copyWith(
      selectedAudioPath: path,
      actionError: null,
    ));
  }

  Future<void> runSpeechToText() async {
    final current = _currentState;
    final path = current.selectedAudioPath;
    if (path == null || path.isEmpty) {
      _updateState(current.copyWith(
        actionError: 'Record audio or pick a file first.',
      ));
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      _updateState(current.copyWith(
        actionError: 'Audio file is missing. Record or pick again.',
      ));
      return;
    }
    _updateState(current.copyWith(
      isSttLoading: true,
      actionError: null,
    ));
    try {
      final lang = current.language.trim();
      final response = await _repository.transcribe(
        audioFile: file,
        language: lang.isEmpty ? null : lang,
      );
      _updateState(_currentState.copyWith(
        isSttLoading: false,
        sttResponse: response,
        transcript: response.text,
        ttsText: response.text,
        actionError: null,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        isSttLoading: false,
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Speech-to-text failed. Please try again.',
        ),
      ));
    }
  }

  Future<void> runTextToSpeech() async {
    final current = _currentState;
    final text = current.ttsText.trim();
    if (text.isEmpty) {
      _updateState(current.copyWith(
        actionError: 'Enter text to speak.',
      ));
      return;
    }
    _updateState(current.copyWith(
      isTtsLoading: true,
      actionError: null,
    ));
    try {
      final result = await _repository.synthesize(text);
      if (result is TtsSuccess) {
        _updateState(_currentState.copyWith(
          isTtsLoading: false,
          lastTtsWavBytes: result.bytes,
          actionError: null,
        ));
      } else if (result is TtsFailure) {
        _updateState(_currentState.copyWith(
          isTtsLoading: false,
          actionError: result.message,
        ));
      }
    } catch (error) {
      _updateState(_currentState.copyWith(
        isTtsLoading: false,
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Text-to-speech failed. Please try again.',
        ),
      ));
    }
  }

  Future<void> runVoiceChat() async {
    final current = _currentState;
    final path = current.selectedAudioPath;
    if (path == null || path.isEmpty) {
      _updateState(current.copyWith(
        actionError: 'Record audio or pick a file first.',
      ));
      return;
    }
    if (current.voiceChatLimitError != null) {
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      _updateState(current.copyWith(
        actionError: 'Audio file is missing. Record or pick again.',
      ));
      return;
    }
    _updateState(current.copyWith(
      isVoiceChatLoading: true,
      actionError: null,
    ));
    try {
      final lang = current.language.trim();
      final response = await _repository.voiceChat(
        projectId: current.currentProjectId,
        audioFile: file,
        limit: current.voiceChatLimit,
        language: lang.isEmpty ? null : lang,
      );
      _updateState(_currentState.copyWith(
        isVoiceChatLoading: false,
        voiceChatResponse: response,
        transcript: response.transcript,
        answer: response.answer,
        ttsText: response.answer,
        lastTtsWavBytes: _decodeOptionalBase64Wav(response.audioBase64),
        actionError: null,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        isVoiceChatLoading: false,
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Voice chat failed. Please try again.',
        ),
      ));
    }
  }

  List<int>? _decodeOptionalBase64Wav(String? base64) {
    if (base64 == null || base64.trim().isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> playLastTtsOrVoiceReply() async {
    final bytes = _currentState.lastTtsWavBytes;
    if (bytes == null || bytes.isEmpty) {
      _updateState(_currentState.copyWith(
        actionError: 'No generated audio yet. Run TTS or voice chat first.',
      ));
      return;
    }
    await _playWavBytes(bytes);
  }

  Future<void> playVoiceChatReplyOnly() async {
    final b64 = _currentState.voiceChatResponse?.audioBase64;
    final decoded = _decodeOptionalBase64Wav(b64);
    if (decoded == null || decoded.isEmpty) {
      _updateState(_currentState.copyWith(
        actionError: 'No voice reply audio in the last response.',
      ));
      return;
    }
    await _playWavBytes(decoded);
  }

  Future<void> _playWavBytes(List<int> bytes) async {
    final s0 = _currentState;
    if (s0.isSttLoading || s0.isTtsLoading || s0.isVoiceChatLoading) {
      return;
    }
    _player ??= AudioPlayer();
    _updateState(_currentState.copyWith(
      isPlayingAudio: true,
      actionError: null,
    ));
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        p.join(dir.path, 'play_${DateTime.now().millisecondsSinceEpoch}.wav'),
      );
      await file.writeAsBytes(bytes, flush: true);
      await _player!.stop();
      await _player!.setFilePath(file.path);
      await _player!.play();
      await _player!.processingStateStream.firstWhere(
        (state) => state == ProcessingState.completed,
      );
    } catch (error) {
      _updateState(_currentState.copyWith(
        actionError: UserFriendlyError.message(
          error,
          fallback: 'Playback failed.',
        ),
      ));
    } finally {
      _updateState(_currentState.copyWith(isPlayingAudio: false));
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _updateState(_currentState.copyWith(isPlayingAudio: false));
  }
}
