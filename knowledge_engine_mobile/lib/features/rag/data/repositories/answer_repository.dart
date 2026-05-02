import '../../../../core/config/app_config.dart';
import '../../../../core/models/rag_answer_response.dart';
import '../../../../core/network/api_service.dart';

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

    _rememberAnswer(
      AnswerRecord(
        projectId: projectId,
        question: text,
        limit: limit,
        response: response,
      ),
    );

    return response;
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
