import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing project data and recent projects
class ProjectsRepository {
  static const String _recentProjectsKey = 'recent_projects';
  static const int _maxRecentProjects = 10;

  final SharedPreferences _prefs;

  ProjectsRepository({required SharedPreferences prefs}) : _prefs = prefs;

  /// Load recent project IDs from local storage
  /// Returns list with newest first
  Future<List<int>> getRecentProjects() async {
    final jsonList = _prefs.getStringList(_recentProjectsKey) ?? [];
    return jsonList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  /// Add project ID to recent projects
  /// Keeps newest first, max 10 items
  Future<void> addRecentProject(int projectId) async {
    if (projectId <= 0) return;

    final recent = await getRecentProjects();

    // Remove if already exists to avoid duplicates
    recent.removeWhere((id) => id == projectId);

    // Add to beginning (newest first)
    recent.insert(0, projectId);

    // Keep only last 10
    if (recent.length > _maxRecentProjects) {
      recent.removeRange(_maxRecentProjects, recent.length);
    }

    // Save back to storage
    await _prefs.setStringList(
      _recentProjectsKey,
      recent.map((e) => e.toString()).toList(),
    );
  }

  /// Clear all recent projects
  Future<void> clearRecentProjects() async {
    await _prefs.remove(_recentProjectsKey);
  }
}
