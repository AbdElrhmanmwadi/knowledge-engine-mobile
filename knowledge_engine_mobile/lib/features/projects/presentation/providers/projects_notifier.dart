import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/projects_repository.dart';

/// State for projects feature
class ProjectsState {
  final String projectInput;
  final bool isLoading;
  final String? errorMessage;
  final String? validationError;

  ProjectsState({
    this.projectInput = '',
    this.isLoading = false,
    this.errorMessage,
    this.validationError,
  });

  ProjectsState copyWith({
    String? projectInput,
    bool? isLoading,
    String? errorMessage,
    String? validationError,
  }) {
    return ProjectsState(
      projectInput: projectInput ?? this.projectInput,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      validationError: validationError,
    );
  }
}

/// Async notifier for projects feature
class ProjectsNotifier extends AsyncNotifier<ProjectsState> {
  late ProjectsRepository repository;

  @override
  Future<ProjectsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    repository = ProjectsRepository(prefs: prefs);
    return ProjectsState();
  }

  /// Update the project input field
  void updateProjectInput(String value) {
    state = AsyncValue.data(
      state.maybeWhen(
            data: (s) => s.copyWith(
              projectInput: value,
              validationError: null,
            ),
            orElse: () => ProjectsState(projectInput: value),
          ),
    );
  }

  /// Validate and open project
  /// Returns true if validation passes
  bool validateAndOpenProject() {
    final currentState = state.maybeWhen(
      data: (s) => s,
      orElse: () => ProjectsState(),
    );
    final input = currentState.projectInput.trim();

    // Check if empty
    if (input.isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(validationError: 'Please enter a project ID'),
      );
      return false;
    }

    // Check if numeric
    final projectId = int.tryParse(input);
    if (projectId == null || projectId <= 0) {
      state = AsyncValue.data(
        currentState.copyWith(
          validationError: 'Project ID must be a positive number',
        ),
      );
      return false;
    }

    // Valid - save to recent projects
    _saveToRecentProjects(projectId);
    return true;
  }

  /// Save project to recent projects list
  Future<void> _saveToRecentProjects(int projectId) async {
    final currentState = state.maybeWhen(
      data: (s) => s,
      orElse: () => ProjectsState(),
    );
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, errorMessage: null),
    );
    try {
      await repository.addRecentProject(projectId);
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Error saving project: $e',
        ),
      );
    }
  }

  /// Clear error messages
  void clearErrors() {
    final currentState = state.maybeWhen(
      data: (s) => s,
      orElse: () => ProjectsState(),
    );
    state = AsyncValue.data(
      currentState.copyWith(errorMessage: null, validationError: null),
    );
  }

  /// Reset the form
  void resetForm() {
    state = AsyncValue.data(ProjectsState());
  }
}

/// Provider for projects notifier
final projectsNotifierProvider =
    AsyncNotifierProvider<ProjectsNotifier, ProjectsState>(
  ProjectsNotifier.new,
);

/// Provider for SharedPreferences (dependency)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
