import 'api_response_base.dart';

/// A file stored under a project, as returned by
/// `GET /api/v1/data/files/{project_id}`.
///
/// [fileName] is the stored unique identifier the backend uses for every
/// other per-file operation (process, delete, translate), NOT a display name.
class ProjectFile {
  const ProjectFile({
    required this.fileId,
    required this.fileName,
    this.fileSize = 0,
    this.fileType,
    this.createdAt,
    this.updatedAt,
  });

  final int fileId;
  final String fileName;
  final int fileSize;
  final String? fileType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectFile.fromJson(JsonMap json) {
    return ProjectFile(
      fileId: ApiResponseBase.readOptionalInt(json, 'file_id') ?? 0,
      fileName: ApiResponseBase.readOptionalString(json, 'file_name') ?? '',
      fileSize: ApiResponseBase.readOptionalInt(json, 'file_size') ?? 0,
      fileType: ApiResponseBase.readOptionalString(json, 'file_type'),
      createdAt: ApiResponseBase.readOptionalDateTime(json, 'file_created_at'),
      updatedAt: ApiResponseBase.readOptionalDateTime(json, 'file_updated_at'),
    );
  }
}
