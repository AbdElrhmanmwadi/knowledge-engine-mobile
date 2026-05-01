import 'api_response_base.dart';

class UploadResponse extends ApiResponseBase {
  const UploadResponse({
    required super.signal,
    required this.fileId,
    this.timestamp,
  });

  final String fileId;
  final DateTime? timestamp;

  factory UploadResponse.fromJson(JsonMap json) {
    return UploadResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      fileId: ApiResponseBase.readRequiredString(json, 'file_id'),
      timestamp: ApiResponseBase.readOptionalDateTime(json, 'timestamp'),
    );
  }

  @override
  UploadResponse copyWith({
    String? signal,
    String? fileId,
    DateTime? timestamp,
  }) {
    return UploadResponse(
      signal: signal ?? this.signal,
      fileId: fileId ?? this.fileId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'file_id': fileId,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}
