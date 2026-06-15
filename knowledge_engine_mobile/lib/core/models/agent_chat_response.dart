import 'api_response_base.dart';

/// A retrieved knowledge chunk that backed an agent answer.
class AgentSource {
  const AgentSource({
    required this.text,
    required this.score,
    this.metadata,
  });

  final String text;
  final double score;
  final JsonMap? metadata;

  factory AgentSource.fromJson(JsonMap json) {
    return AgentSource(
      text: ApiResponseBase.readOptionalString(json, 'text') ?? '',
      score: ApiResponseBase.readOptionalDouble(json, 'score') ?? 0,
      metadata: ApiResponseBase.readOptionalJsonMap(json, 'metadata'),
    );
  }
}

/// Reply from `POST /api/v1/agent/chat/{projectId}` (non-streaming).
///
/// [sessionId] must be sent back on the next turn so the agent keeps the
/// conversation context.
class AgentChatResponse {
  const AgentChatResponse({
    required this.sessionId,
    required this.answer,
    this.sources = const <AgentSource>[],
  });

  final int sessionId;
  final String answer;
  final List<AgentSource> sources;

  factory AgentChatResponse.fromJson(JsonMap json) {
    return AgentChatResponse(
      sessionId: ApiResponseBase.readRequiredInt(json, 'session_id'),
      answer: ApiResponseBase.readOptionalString(json, 'answer') ?? '',
      sources:
          (ApiResponseBase.readOptionalJsonMapList(json, 'sources') ??
                  const <JsonMap>[])
              .map(AgentSource.fromJson)
              .toList(growable: false),
    );
  }
}
