import 'api_response_base.dart';

/// A project owned by the current user, as returned by
/// `GET /api/v1/projects`.
class ProjectSummary {
  const ProjectSummary({
    required this.projectId,
    this.projectUuid,
    this.createdAt,
    this.updatedAt,
  });

  final int projectId;
  final String? projectUuid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectSummary.fromJson(JsonMap json) {
    return ProjectSummary(
      projectId: ApiResponseBase.readRequiredInt(json, 'project_id'),
      projectUuid: ApiResponseBase.readOptionalString(json, 'project_uuid'),
      createdAt: ApiResponseBase.readOptionalDateTime(json, 'created_at'),
      updatedAt: ApiResponseBase.readOptionalDateTime(json, 'updated_at'),
    );
  }
}
