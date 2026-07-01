import '../../../../core/models/feedback_response.dart';
import '../../../../core/network/api_service.dart';

/// Repository wrapper for submitting 👍/👎 answer feedback.
///
/// Shared by both answer surfaces: the RAG Ask page (direct answers, no
/// session) and the Agent chat (pass the active `sessionId`).
class FeedbackRepository {
  FeedbackRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  Future<FeedbackResponse> submitFeedback({
    required int projectId,
    required String question,
    required String answer,
    required int rating,
    int? sessionId,
    String? comment,
  }) {
    return _apiService.submitFeedback(
      projectId: projectId,
      question: question,
      answer: answer,
      rating: rating,
      sessionId: sessionId,
      comment: comment,
    );
  }
}
