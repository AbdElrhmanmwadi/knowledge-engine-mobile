import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/projects_notifier.dart';
import '../providers/recent_projects_provider.dart';
import 'package:knowledge_engine_mobile/core/widgets/app_button.dart';
import 'package:knowledge_engine_mobile/core/widgets/app_card.dart';

/// Projects Page - First screen for project selection
/// Allows users to enter a project ID and view recent projects
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(projectsNotifierProvider);
    final notifier = ref.read(projectsNotifierProvider.notifier);
    final recentProjects = ref.watch(recentProjectsProvider);

    return stateAsync.when(
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Knowledge Engine'),
            centerTitle: false,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Welcome section
                  _buildWelcomeSection(context),
                  const SizedBox(height: 32),
                  // Project ID input section
                  _buildProjectInputSection(context, state, notifier),
                  const SizedBox(height: 24),
                  // Error messages
                  if (state.errorMessage != null)
                    _buildErrorMessage(state.errorMessage!),
                  const SizedBox(height: 32),
                  // Recent projects section
                  _buildRecentProjectsSection(context, recentProjects, notifier),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Knowledge Engine'),
          centerTitle: false,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Knowledge Engine'),
          centerTitle: false,
          elevation: 0,
        ),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  /// Build welcome header section
  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your project ID to get started',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Build project ID input section
  Widget _buildProjectInputSection(
    BuildContext context,
    ProjectsState state,
    ProjectsNotifier notifier,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project ID',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // Text input field
          TextField(
            keyboardType: TextInputType.number,
            onChanged: notifier.updateProjectInput,
            decoration: InputDecoration(
              hintText: 'Enter project ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: state.validationError,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Open Project button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Open Project',
              isLoading: state.isLoading,
              onPressed: () {
                if (notifier.validateAndOpenProject()) {
                  final projectId = int.tryParse(state.projectInput.trim());
                  if (projectId != null) {
                    context.push('/dashboard', extra: projectId);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message display
  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build recent projects section
  Widget _buildRecentProjectsSection(
    BuildContext context,
    AsyncValue<List<int>> recentProjects,
    ProjectsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Projects',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        recentProjects.when(
          data: (projects) {
            if (projects.isEmpty) {
              return AppCard(
                child: Center(
                  child: Text(
                    'No recent projects',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: projects.map((projectId) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildRecentProjectTile(
                    context,
                    projectId,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => AppCard(
            child: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          error: (error, stack) => AppCard(
            child: Text(
              'Error loading recent projects: $error',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ),
      ],
    );
  }

  /// Build individual recent project tile
  Widget _buildRecentProjectTile(BuildContext context, int projectId) {
    return GestureDetector(
      onTap: () {
        context.push('/dashboard', extra: projectId);
      },
      child: AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  projectId.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
