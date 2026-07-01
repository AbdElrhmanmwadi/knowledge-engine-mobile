import 'api_response_base.dart';

/// Response returned when a 👍/👎 rating is submitted for an answer.
class FeedbackResponse extends ApiResponseBase {
  const FeedbackResponse({
    required super.signal,
    required this.feedbackId,
  });

  final int feedbackId;

  factory FeedbackResponse.fromJson(JsonMap json) {
    return FeedbackResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      feedbackId: ApiResponseBase.readRequiredInt(json, 'feedback_id'),
    );
  }

  @override
  FeedbackResponse copyWith({
    String? signal,
    int? feedbackId,
  }) {
    return FeedbackResponse(
      signal: signal ?? this.signal,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'feedback_id': feedbackId,
    };
  }
}
