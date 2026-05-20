import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/files/presentation/pages/files_page.dart';
import 'features/rag/presentation/pages/ask_page.dart';
import 'features/translation/presentation/pages/translate_page.dart';
import 'features/voice/presentation/pages/voice_page.dart';

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
});

/// Main application widget with routing configuration
class KnowledgeEngineApp extends ConsumerWidget {
  const KnowledgeEngineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    if (onboardingCompleted.isLoading) {
      return MaterialApp(
        title: 'Knowledge Engine',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const _StartupScreen(),
      );
    }

    final hasSeenOnboarding = onboardingCompleted.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    return MaterialApp.router(
      title: 'Knowledge Engine',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: createRouter(hasSeenOnboarding: hasSeenOnboarding),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// GoRouter configuration
GoRouter createRouter({required bool hasSeenOnboarding}) => GoRouter(
  initialLocation: hasSeenOnboarding ? '/projects' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
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

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
