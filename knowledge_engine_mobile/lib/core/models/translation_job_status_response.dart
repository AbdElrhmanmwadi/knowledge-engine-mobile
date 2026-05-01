import 'api_response_base.dart';

class TranslationJobStatusDetails {
  const TranslationJobStatusDetails({
    required this.jobId,
    required this.status,
    this.resultFileId,
    this.errorMessage,
    this.progressPercentage,
  });

  final String jobId;
  final String status;
  final String? resultFileId;
  final String? errorMessage;
  final int? progressPercentage;

  factory TranslationJobStatusDetails.fromJson(JsonMap json) {
    return TranslationJobStatusDetails(
      jobId: ApiResponseBase.readRequiredString(json, 'job_id'),
      status: ApiResponseBase.readRequiredString(json, 'status'),
      resultFileId: ApiResponseBase.readOptionalString(json, 'result_file_id'),
      errorMessage: ApiResponseBase.readOptionalString(json, 'error_message'),
      progressPercentage: ApiResponseBase.readOptionalInt(
        json,
        'progress_percentage',
      ),
    );
  }

  TranslationJobStatusDetails copyWith({
    String? jobId,
    String? status,
    String? resultFileId,
    String? errorMessage,
    int? progressPercentage,
  }) {
    return TranslationJobStatusDetails(
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      resultFileId: resultFileId ?? this.resultFileId,
      errorMessage: errorMessage ?? this.errorMessage,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'job_id': jobId,
      'status': status,
      if (resultFileId != null) 'result_file_id': resultFileId,
      if (errorMessage != null) 'error_message': errorMessage,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
    };
  }
}

class TranslationJobStatusResponse extends ApiResponseBase {
  const TranslationJobStatusResponse({
    required super.signal,
    required this.job,
  });

  final TranslationJobStatusDetails job;

  factory TranslationJobStatusResponse.fromJson(JsonMap json) {
    return TranslationJobStatusResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      job: TranslationJobStatusDetails.fromJson(
        ApiResponseBase.readRequiredJsonMap(json, 'job'),
      ),
    );
  }

  @override
  TranslationJobStatusResponse copyWith({
    String? signal,
    TranslationJobStatusDetails? job,
  }) {
    return TranslationJobStatusResponse(
      signal: signal ?? this.signal,
      job: job ?? this.job,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{'signal': signal, 'job': job.toJson()};
  }
}
