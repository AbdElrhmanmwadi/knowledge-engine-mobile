import 'package:dio/dio.dart';

import '../../../../core/models/agent_chat_response.dart';
import '../../../../core/models/agent_session.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/sse_parser.dart';

/// Repository wrapper for the conversational agent: chat plus session
/// management.
class AgentRepository {
  AgentRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  Future<AgentChatResponse> chat({
    required int projectId,
    required String message,
    int? sessionId,
    int? limit,
  }) {
    return _apiService.agentChat(
      projectId: projectId,
      message: message,
      sessionId: sessionId,
      limit: limit,
    );
  }

  Stream<SseEvent> chatStream({
    required int projectId,
    required String message,
    int? sessionId,
    int? limit,
    CancelToken? cancelToken,
  }) {
    return _apiService.agentChatStream(
      projectId: projectId,
      message: message,
      sessionId: sessionId,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<List<AgentSessionSummary>> listSessions(int projectId) {
    return _apiService.agentSessions(projectId: projectId);
  }

  Future<AgentSession> getSession(int projectId, int sessionId) {
    return _apiService.agentSession(
      projectId: projectId,
      sessionId: sessionId,
    );
  }

  Future<void> deleteSession(int projectId, int sessionId) {
    return _apiService.deleteAgentSession(
      projectId: projectId,
      sessionId: sessionId,
    );
  }
}
