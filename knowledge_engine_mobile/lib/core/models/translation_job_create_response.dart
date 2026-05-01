import 'api_response_base.dart';

class TranslationJobCreateResponse extends ApiResponseBase {
  const TranslationJobCreateResponse({
    required super.signal,
    required this.jobId,
    required this.status,
    required this.assetId,
    required this.sourceLang,
    required this.targetLang,
    this.createdAt,
  });

  final String jobId;
  final String status;
  final String assetId;
  final String sourceLang;
  final String targetLang;
  final DateTime? createdAt;

  factory TranslationJobCreateResponse.fromJson(JsonMap json) {
    return TranslationJobCreateResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      jobId: ApiResponseBase.readRequiredString(json, 'job_id'),
      status: ApiResponseBase.readRequiredString(json, 'status'),
      assetId: ApiResponseBase.readRequiredString(json, 'asset_id'),
      sourceLang: ApiResponseBase.readRequiredString(json, 'source_lang'),
      targetLang: ApiResponseBase.readRequiredString(json, 'target_lang'),
      createdAt: ApiResponseBase.readOptionalDateTime(json, 'created_at'),
    );
  }

  @override
  TranslationJobCreateResponse copyWith({
    String? signal,
    String? jobId,
    String? status,
    String? assetId,
    String? sourceLang,
    String? targetLang,
    DateTime? createdAt,
  }) {
    return TranslationJobCreateResponse(
      signal: signal ?? this.signal,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      assetId: assetId ?? this.assetId,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'job_id': jobId,
      'status': status,
      'asset_id': assetId,
      'source_lang': sourceLang,
      'target_lang': targetLang,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
