import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/projects_repository.dart';

/// Provider for recent projects list
final recentProjectsProvider = FutureProvider<List<int>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final repository = ProjectsRepository(prefs: prefs);
  return repository.getRecentProjects();
});

/// Provider for refreshing recent projects
final refreshRecentProjectsProvider = FutureProvider<void>((ref) async {
  // Invalidate the recent projects provider to force a refresh
  ref.invalidate(recentProjectsProvider);
});
