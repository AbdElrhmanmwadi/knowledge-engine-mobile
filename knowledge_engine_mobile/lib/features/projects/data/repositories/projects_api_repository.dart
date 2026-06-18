import '../../../../core/models/api_response_base.dart';
import '../../../../core/models/project_file.dart';
import '../../../../core/models/project_summary.dart';
import '../../../../core/network/api_service.dart';

/// Repository wrapper for project-related API operations.
class ProjectsApiRepository {
  ProjectsApiRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  Future<List<ProjectSummary>> listProjects() {
    return _apiService.listProjects();
  }

  Future<List<ProjectFile>> listProjectFiles(int projectId) {
    return _apiService.listProjectFiles(projectId: projectId);
  }

  Future<JsonMap> deleteAllProjectFiles({
    required int projectId,
  }) {
    return _apiService.deleteAllProjectFiles(projectId: projectId);
  }
}

