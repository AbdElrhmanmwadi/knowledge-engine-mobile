import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/project_file.dart';
import '../../../../core/models/project_summary.dart';
import '../../data/repositories/projects_api_repository.dart';
import '../../data/repositories/projects_repository.dart';

/// Provider for recent projects list
final recentProjectsProvider = FutureProvider<List<int>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = ProjectsRepository(prefs: prefs);
  return repository.getRecentProjects();
});

/// The current user's projects fetched from the backend (newest first).
final projectsListProvider =
    FutureProvider.autoDispose<List<ProjectSummary>>((ref) async {
  return ProjectsApiRepository().listProjects();
});

/// Files stored under a given project, fetched from the backend.
final projectFilesProvider =
    FutureProvider.autoDispose.family<List<ProjectFile>, int>(
  (ref, projectId) async {
    return ProjectsApiRepository().listProjectFiles(projectId);
  },
);

/// Provider for refreshing recent projects
final refreshRecentProjectsProvider = FutureProvider<void>((ref) async {
  // Invalidate the recent projects provider to force a refresh
  ref.invalidate(recentProjectsProvider);
});
