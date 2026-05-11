import '../../../../core/models/api_response_base.dart';
import '../../../../core/network/api_service.dart';

/// Repository wrapper for project-related API operations.
class ProjectsApiRepository {
  ProjectsApiRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  Future<JsonMap> deleteAllProjectFiles({
    required int projectId,
  }) {
    return _apiService.deleteAllProjectFiles(projectId: projectId);
  }
}

