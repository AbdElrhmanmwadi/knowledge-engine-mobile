import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Engine'**
  String get appTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @goToProjects.
  ///
  /// In en, this message translates to:
  /// **'Go to Projects'**
  String get goToProjects;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {location}'**
  String routeNotFound(Object location);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize knowledge'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeBody.
  ///
  /// In en, this message translates to:
  /// **'Create project spaces for documents, questions, translations, and voice notes.'**
  String get onboardingOrganizeBody;

  /// No description provided for @onboardingAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask with context'**
  String get onboardingAskTitle;

  /// No description provided for @onboardingAskBody.
  ///
  /// In en, this message translates to:
  /// **'Upload files, index them, and get answers grounded in your own material.'**
  String get onboardingAskBody;

  /// No description provided for @onboardingFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Work across formats'**
  String get onboardingFormatsTitle;

  /// No description provided for @onboardingFormatsBody.
  ///
  /// In en, this message translates to:
  /// **'Move between search, translation, and audio workflows from one focused workspace.'**
  String get onboardingFormatsBody;

  /// No description provided for @openProject.
  ///
  /// In en, this message translates to:
  /// **'Open Project'**
  String get openProject;

  /// No description provided for @recentProjects.
  ///
  /// In en, this message translates to:
  /// **'Recent Projects'**
  String get recentProjects;

  /// No description provided for @projectId.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get projectId;

  /// No description provided for @projectIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 42'**
  String get projectIdHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @opening.
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get opening;

  /// No description provided for @knowledgeEngineUpper.
  ///
  /// In en, this message translates to:
  /// **'KNOWLEDGE ENGINE'**
  String get knowledgeEngineUpper;

  /// No description provided for @projectsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your projects,\nat a glance'**
  String get projectsHeroTitle;

  /// No description provided for @projectsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a project ID or pick a recent one'**
  String get projectsHeroSubtitle;

  /// No description provided for @couldNotDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete Project {id}.'**
  String couldNotDeleteProject(int id);

  /// No description provided for @errorLoadingRecentProjects.
  ///
  /// In en, this message translates to:
  /// **'Error loading recent projects: {message}'**
  String errorLoadingRecentProjects(Object message);

  /// No description provided for @noRecentProjects.
  ///
  /// In en, this message translates to:
  /// **'No recent projects yet'**
  String get noRecentProjects;

  /// No description provided for @openProjectAbove.
  ///
  /// In en, this message translates to:
  /// **'Open a project above to see it here'**
  String get openProjectAbove;

  /// No description provided for @projectNumber.
  ///
  /// In en, this message translates to:
  /// **'Project #{id}'**
  String projectNumber(int id);

  /// No description provided for @tapToOpenSwipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Tap to open · swipe to delete'**
  String get tapToOpenSwipeToDelete;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
