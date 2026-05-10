import 'api_response_base.dart';

class TranslationJobStatusDetails {
  const TranslationJobStatusDetails({
    required this.jobId,
    required this.status,
    this.assetId,
    this.sourceLang,
    this.targetLang,
    this.resultAssetId,
    this.resultFileId,
    this.errorMessage,
    this.progressPercentage,
  });

  final String jobId;
  final String status;
  final String? assetId;
  final String? sourceLang;
  final String? targetLang;
  final String? resultAssetId;
  final String? resultFileId;
  final String? errorMessage;
  final int? progressPercentage;

  factory TranslationJobStatusDetails.fromJson(JsonMap json) {
    return TranslationJobStatusDetails(
      jobId: ApiResponseBase.readRequiredString(json, 'job_id'),
      status: ApiResponseBase.readRequiredString(json, 'status'),
      assetId: ApiResponseBase.readOptionalString(json, 'asset_id'),
      sourceLang: ApiResponseBase.readOptionalString(json, 'source_lang'),
      targetLang: ApiResponseBase.readOptionalString(json, 'target_lang'),
      resultAssetId: ApiResponseBase.readOptionalString(json, 'result_asset_id'),
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
    String? assetId,
    String? sourceLang,
    String? targetLang,
    String? resultAssetId,
    String? resultFileId,
    String? errorMessage,
    int? progressPercentage,
  }) {
    return TranslationJobStatusDetails(
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      assetId: assetId ?? this.assetId,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      resultAssetId: resultAssetId ?? this.resultAssetId,
      resultFileId: resultFileId ?? this.resultFileId,
      errorMessage: errorMessage ?? this.errorMessage,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'job_id': jobId,
      'status': status,
      if (assetId != null) 'asset_id': assetId,
      if (sourceLang != null) 'source_lang': sourceLang,
      if (targetLang != null) 'target_lang': targetLang,
      if (resultAssetId != null) 'result_asset_id': resultAssetId,
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
