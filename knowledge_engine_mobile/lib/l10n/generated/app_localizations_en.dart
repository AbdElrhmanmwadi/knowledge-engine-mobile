// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Knowledge Engine';

  @override
  String get error => 'Error';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get goToProjects => 'Go to Projects';

  @override
  String routeNotFound(Object location) {
    return 'Route not found: $location';
  }

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingOrganizeTitle => 'Organize knowledge';

  @override
  String get onboardingOrganizeBody =>
      'Create project spaces for documents, questions, translations, and voice notes.';

  @override
  String get onboardingAskTitle => 'Ask with context';

  @override
  String get onboardingAskBody =>
      'Upload files, index them, and get answers grounded in your own material.';

  @override
  String get onboardingFormatsTitle => 'Work across formats';

  @override
  String get onboardingFormatsBody =>
      'Move between search, translation, and audio workflows from one focused workspace.';

  @override
  String get openProject => 'Open Project';

  @override
  String get recentProjects => 'Recent Projects';

  @override
  String get projectId => 'Project ID';

  @override
  String get projectIdHint => 'e.g. 42';

  @override
  String get clear => 'Clear';

  @override
  String get opening => 'Opening...';

  @override
  String get knowledgeEngineUpper => 'KNOWLEDGE ENGINE';

  @override
  String get projectsHeroTitle => 'Your projects,\nat a glance';

  @override
  String get projectsHeroSubtitle => 'Enter a project ID or pick a recent one';

  @override
  String couldNotDeleteProject(int id) {
    return 'Couldn\'t delete Project $id.';
  }

  @override
  String errorLoadingRecentProjects(Object message) {
    return 'Error loading recent projects: $message';
  }

  @override
  String get noRecentProjects => 'No recent projects yet';

  @override
  String get openProjectAbove => 'Open a project above to see it here';

  @override
  String projectNumber(int id) {
    return 'Project #$id';
  }

  @override
  String get tapToOpenSwipeToDelete => 'Tap to open · swipe to delete';

  @override
  String get delete => 'Delete';
}
