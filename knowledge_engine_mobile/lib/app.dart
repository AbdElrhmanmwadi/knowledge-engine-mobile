import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'l10n/l10n.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/verify_email_page.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/agent/presentation/pages/agent_chat_page.dart';
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

const _supportedLocales = [
  Locale('en'),
  Locale('ar'),
];

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Main application widget with routing configuration
class KnowledgeEngineApp extends ConsumerWidget {
  const KnowledgeEngineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final authStatus = ref.watch(authNotifierProvider);

    if (onboardingCompleted.isLoading || authStatus == AuthStatus.unknown) {
      return MaterialApp(
        title: 'Knowledge Engine',
        locale: locale,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: _supportedLocales,
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
      locale: locale,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: _supportedLocales,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: createRouter(
        hasSeenOnboarding: hasSeenOnboarding,
        authStatus: authStatus,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Routes reachable without a session.
const Set<String> _publicPaths = {
  '/onboarding',
  '/login',
  '/register',
  '/auth/forgot-password',
  '/auth/reset-password',
  '/auth/verify-email',
};

/// GoRouter configuration
GoRouter createRouter({
  required bool hasSeenOnboarding,
  required AuthStatus authStatus,
}) => GoRouter(
  initialLocation: !hasSeenOnboarding
      ? '/onboarding'
      : authStatus == AuthStatus.authenticated
          ? '/projects'
          : '/login',
  redirect: (context, state) {
    final isAuthenticated = authStatus == AuthStatus.authenticated;
    final location = state.matchedLocation;
    final isPublic = _publicPaths.contains(location);

    if (!isAuthenticated && !isPublic) {
      return '/login';
    }
    if (isAuthenticated && (location == '/login' || location == '/register')) {
      return '/projects';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/auth/reset-password',
      builder: (context, state) =>
          ResetPasswordPage(token: state.uri.queryParameters['token']),
    ),
    GoRoute(
      path: '/auth/verify-email',
      builder: (context, state) =>
          VerifyEmailPage(token: state.uri.queryParameters['token']),
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
      path: '/agent',
      builder: (context, state) {
        final projectId = state.extra as int?;
        if (projectId == null) {
          return const ProjectsPage();
        }
        return AgentChatPage(projectId: projectId);
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
    appBar: AppBar(title: Text(context.l10n.error)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.routeNotFound(state.matchedLocation)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.go('/projects'),
            child: Text(context.l10n.goToProjects),
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
