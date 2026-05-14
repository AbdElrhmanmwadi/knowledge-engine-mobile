import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/files/presentation/pages/files_page.dart';
import 'features/rag/presentation/pages/ask_page.dart';
import 'features/translation/presentation/pages/translate_page.dart';
import 'features/voice/presentation/pages/voice_page.dart';

/// Main application widget with routing configuration
class KnowledgeEngineApp extends StatelessWidget {
  const KnowledgeEngineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Knowledge Engine',
      theme: AppTheme.lightTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/projects',
  routes: [
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return DashboardPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/files',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return FilesPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/ask',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return AskPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/translate',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return TranslatePage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return VoicePage(projectId: projectId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Route not found: ${state.matchedLocation}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/projects'),
            child: const Text('Go to Projects'),
          ),
        ],
      ),
    ),
  ),
);
