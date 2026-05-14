import 'dart:io';

import '../../../../core/models/stt_response.dart';
import '../../../../core/models/tts_result.dart';
import '../../../../core/models/voice_chat_response.dart';
import '../../../../core/network/api_service.dart';

/// Repository for voice STT, TTS, and project-scoped voice chat.
class VoiceRepository {
  VoiceRepository({
    ApiService? apiService,
  }) : _api = apiService ?? DioApiService();

  final ApiService _api;

  Future<SttResponse> transcribe({
    required File audioFile,
    String? language,
  }) {
    return _api.speechToText(
      audioFile: audioFile,
      language: language,
    );
  }

  Future<TtsResult> synthesize(String text) {
    return _api.textToSpeech(text: text);
  }

  Future<VoiceChatResponse> voiceChat({
    required int projectId,
    required File audioFile,
    int limit = 30,
    String? language,
  }) {
    return _api.voiceChat(
      projectId: projectId,
      audioFile: audioFile,
      limit: limit,
      returnAudioBase64: true,
      language: language,
    );
  }
}
