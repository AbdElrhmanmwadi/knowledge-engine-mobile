import 'api_response_base.dart';

/// Response from `POST /api/v1/voice/chat/{project_id}` when `return_audio_base64` is true.
class VoiceChatResponse extends ApiResponseBase {
  const VoiceChatResponse({
    required super.signal,
    required this.transcript,
    required this.answer,
    this.audioBase64,
    this.audioMimeType,
    this.fullPrompt,
    this.chatHistory,
  });

  final String transcript;
  final String answer;
  final String? audioBase64;
  final String? audioMimeType;
  final String? fullPrompt;
  final List<JsonMap>? chatHistory;

  factory VoiceChatResponse.fromJson(JsonMap json) {
    return VoiceChatResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      transcript: ApiResponseBase.readRequiredString(json, 'transcript'),
      answer: ApiResponseBase.readRequiredString(json, 'answer'),
      audioBase64: ApiResponseBase.readOptionalString(json, 'audio_base64'),
      audioMimeType: ApiResponseBase.readOptionalString(json, 'audio_mime_type'),
      fullPrompt: ApiResponseBase.readOptionalString(json, 'full_prompt'),
      chatHistory: ApiResponseBase.readOptionalJsonMapList(json, 'chat_history'),
    );
  }

  @override
  VoiceChatResponse copyWith({
    String? signal,
    String? transcript,
    String? answer,
    String? audioBase64,
    String? audioMimeType,
    String? fullPrompt,
    List<JsonMap>? chatHistory,
  }) {
    return VoiceChatResponse(
      signal: signal ?? this.signal,
      transcript: transcript ?? this.transcript,
      answer: answer ?? this.answer,
      audioBase64: audioBase64 ?? this.audioBase64,
      audioMimeType: audioMimeType ?? this.audioMimeType,
      fullPrompt: fullPrompt ?? this.fullPrompt,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'transcript': transcript,
      'answer': answer,
      if (audioBase64 != null) 'audio_base64': audioBase64,
      if (audioMimeType != null) 'audio_mime_type': audioMimeType,
      if (fullPrompt != null) 'full_prompt': fullPrompt,
      if (chatHistory != null) 'chat_history': chatHistory,
    };
  }
}
