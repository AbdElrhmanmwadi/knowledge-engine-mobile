import 'api_response_base.dart';

class ProcessResponse extends ApiResponseBase {
  const ProcessResponse({
    required super.signal,
    required this.insertedChunks,
    required this.processedFiles,
    this.fileId,
    this.chunkSize,
    this.overlapSize,
  });

  final String? fileId;
  final int insertedChunks;
  final int processedFiles;
  final int? chunkSize;
  final int? overlapSize;

  factory ProcessResponse.fromJson(JsonMap json) {
    return ProcessResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      fileId: ApiResponseBase.readOptionalString(json, 'file_id'),
      insertedChunks: ApiResponseBase.readRequiredInt(json, 'inserted_chunks'),
      processedFiles: ApiResponseBase.readRequiredInt(json, 'processed_files'),
      chunkSize: ApiResponseBase.readOptionalInt(json, 'chunk_size'),
      overlapSize: ApiResponseBase.readOptionalInt(json, 'overlap_size'),
    );
  }

  @override
  ProcessResponse copyWith({
    String? signal,
    String? fileId,
    int? insertedChunks,
    int? processedFiles,
    int? chunkSize,
    int? overlapSize,
  }) {
    return ProcessResponse(
      signal: signal ?? this.signal,
      fileId: fileId ?? this.fileId,
      insertedChunks: insertedChunks ?? this.insertedChunks,
      processedFiles: processedFiles ?? this.processedFiles,
      chunkSize: chunkSize ?? this.chunkSize,
      overlapSize: overlapSize ?? this.overlapSize,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'inserted_chunks': insertedChunks,
      'processed_files': processedFiles,
      if (fileId != null) 'file_id': fileId,
      if (chunkSize != null) 'chunk_size': chunkSize,
      if (overlapSize != null) 'overlap_size': overlapSize,
    };
  }
}
