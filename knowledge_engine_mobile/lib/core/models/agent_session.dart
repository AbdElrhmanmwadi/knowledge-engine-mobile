import 'agent_chat_response.dart';
import 'api_response_base.dart';

/// A single stored message in a persisted agent session.
class AgentMessage {
  const AgentMessage({
    required this.role,
    required this.content,
    this.metadata = const <String, dynamic>{},
  });

  /// "user" | "assistant"
  final String role;
  final String content;

  /// On assistant messages this carries `{sources, tool_trace}`.
  final JsonMap metadata;

  bool get isUser => role == 'user';

  /// The retrieved chunks behind an assistant message, if any.
  List<AgentSource> get sources {
    final raw = metadata['sources'];
    if (raw is! List) {
      return const <AgentSource>[];
    }
    return raw
        .whereType<Map>()
        .map(
          (item) => AgentSource.fromJson(
            item.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList(growable: false);
  }

  factory AgentMessage.fromJson(JsonMap json) {
    return AgentMessage(
      role: ApiResponseBase.readOptionalString(json, 'role') ?? 'assistant',
      content: ApiResponseBase.readOptionalString(json, 'content') ?? '',
      metadata: ApiResponseBase.readOptionalJsonMap(json, 'metadata') ??
          const <String, dynamic>{},
    );
  }
}

/// One conversation with its full message history.
class AgentSession {
  const AgentSession({
    required this.sessionId,
    required this.projectId,
    required this.title,
    this.messages = const <AgentMessage>[],
  });

  final int sessionId;
  final int projectId;
  final String title;
  final List<AgentMessage> messages;

  factory AgentSession.fromJson(JsonMap json) {
    return AgentSession(
      sessionId: ApiResponseBase.readRequiredInt(json, 'session_id'),
      projectId: ApiResponseBase.readOptionalInt(json, 'project_id') ?? 0,
      title: ApiResponseBase.readOptionalString(json, 'title') ?? '',
      messages:
          (ApiResponseBase.readOptionalJsonMapList(json, 'messages') ??
                  const <JsonMap>[])
              .map(AgentMessage.fromJson)
              .toList(growable: false),
    );
  }
}

/// Lightweight session entry returned by the session-list endpoint.
class AgentSessionSummary {
  const AgentSessionSummary({
    required this.sessionId,
    required this.title,
  });

  final int sessionId;
  final String title;

  factory AgentSessionSummary.fromJson(JsonMap json) {
    return AgentSessionSummary(
      sessionId: ApiResponseBase.readRequiredInt(json, 'session_id'),
      title: ApiResponseBase.readOptionalString(json, 'title') ?? '',
    );
  }
}
