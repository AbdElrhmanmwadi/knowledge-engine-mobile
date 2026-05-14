import 'api_response_base.dart';

/// Response from `POST /api/v1/voice/stt` on success.
class SttResponse extends ApiResponseBase {
  const SttResponse({
    required super.signal,
    required this.text,
    this.language,
    this.durationMs,
  });

  final String text;
  final String? language;
  final int? durationMs;

  factory SttResponse.fromJson(JsonMap json) {
    return SttResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      text: ApiResponseBase.readRequiredString(json, 'text'),
      language: ApiResponseBase.readOptionalString(json, 'language'),
      durationMs: ApiResponseBase.readOptionalInt(json, 'duration_ms'),
    );
  }

  @override
  SttResponse copyWith({
    String? signal,
    String? text,
    String? language,
    int? durationMs,
  }) {
    return SttResponse(
      signal: signal ?? this.signal,
      text: text ?? this.text,
      language: language ?? this.language,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'text': text,
      if (language != null) 'language': language,
      if (durationMs != null) 'duration_ms': durationMs,
    };
  }
}
