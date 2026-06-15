import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/rag_answer_response.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/sse_parser.dart';

/// Lightweight in-memory record for recent answer requests.
class AnswerRecord {
  const AnswerRecord({
    required this.projectId,
    required this.question,
    required this.limit,
    required this.response,
  });

  final int projectId;
  final String question;
  final int limit;
  final RagAnswerResponse response;
}

/// Repository wrapper for RAG answer generation.
class AnswerRepository {
  AnswerRepository({
    ApiService? apiService,
    this.maxCacheEntries = 10,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;
  final int maxCacheEntries;
  final List<AnswerRecord> _recentAnswers = <AnswerRecord>[];

  List<AnswerRecord> get recentAnswers =>
      List<AnswerRecord>.unmodifiable(_recentAnswers);

  Future<RagAnswerResponse> askQuestion({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultRagLimit,
  }) async {
    final response = await _apiService.askQuestion(
      projectId: projectId,
      text: text,
      limit: limit,
    );

    rememberAnswer(
      projectId: projectId,
      question: text,
      limit: limit,
      response: response,
    );

    return response;
  }

  /// Stream a RAG answer token-by-token. The notifier accumulates the events
  /// and calls [rememberAnswer] once the final answer is assembled.
  Stream<SseEvent> askQuestionStream({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultRagLimit,
    CancelToken? cancelToken,
  }) {
    return _apiService.askQuestionStream(
      projectId: projectId,
      text: text,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  /// Record a completed answer in the recent-answers cache.
  void rememberAnswer({
    required int projectId,
    required String question,
    required int limit,
    required RagAnswerResponse response,
  }) {
    _rememberAnswer(
      AnswerRecord(
        projectId: projectId,
        question: question,
        limit: limit,
        response: response,
      ),
    );
  }

  void clearCache() {
    _recentAnswers.clear();
  }

  void _rememberAnswer(AnswerRecord record) {
    _recentAnswers.insert(0, record);
    if (_recentAnswers.length > maxCacheEntries) {
      _recentAnswers.removeRange(maxCacheEntries, _recentAnswers.length);
    }
  }
}
