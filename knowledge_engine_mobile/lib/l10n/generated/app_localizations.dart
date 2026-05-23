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

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @projectBadge.
  ///
  /// In en, this message translates to:
  /// **'PROJECT {id}'**
  String projectBadge(int id);

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @addYourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add your\\ndocuments'**
  String get addYourDocuments;

  /// No description provided for @uploadPrepareIndexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload · prepare · index into knowledge base'**
  String get uploadPrepareIndexSubtitle;

  /// No description provided for @stepUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get stepUpload;

  /// No description provided for @stepPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get stepPrepare;

  /// No description provided for @stepIndex.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get stepIndex;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @statusLogCopied.
  ///
  /// In en, this message translates to:
  /// **'Status log copied.'**
  String get statusLogCopied;

  /// No description provided for @synthesize.
  ///
  /// In en, this message translates to:
  /// **'Synthesize'**
  String get synthesize;

  /// No description provided for @pickAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Pick audio file'**
  String get pickAudioFile;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @promptCopied.
  ///
  /// In en, this message translates to:
  /// **'Prompt copied to clipboard.'**
  String get promptCopied;

  /// No description provided for @secondsWithCount.
  ///
  /// In en, this message translates to:
  /// **'{s} seconds'**
  String secondsWithCount(Object s);

  /// No description provided for @askPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask & Search'**
  String get askPageTitle;

  /// No description provided for @askLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get askLeftLabel;

  /// No description provided for @askRightLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askRightLabel;

  /// No description provided for @askHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & ask across\\nyour knowledge'**
  String get askHeroTitle;

  /// No description provided for @askHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Semantic search · RAG answers · debug traces'**
  String get askHeroSubtitle;

  /// No description provided for @workspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspaceTitle;

  /// No description provided for @dashboardPrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get dashboardPrompt;

  /// No description provided for @featureDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload & index files'**
  String get featureDocumentsDesc;

  /// No description provided for @featureAskDesc.
  ///
  /// In en, this message translates to:
  /// **'Search & get answers'**
  String get featureAskDesc;

  /// No description provided for @featureVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get featureVoiceTitle;

  /// No description provided for @featureVoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Speak, transcribe, listen'**
  String get featureVoiceDesc;

  /// No description provided for @featureTranslateDesc.
  ///
  /// In en, this message translates to:
  /// **'Translate & download'**
  String get featureTranslateDesc;

  /// No description provided for @projectReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your project\\nis ready'**
  String get projectReadyTitle;

  /// No description provided for @projectReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what you want to do next.'**
  String get projectReadySubtitle;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Studio'**
  String get voiceTitle;

  /// No description provided for @micAccessOff.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off. Enable it in system settings.'**
  String get micAccessOff;

  /// No description provided for @audioSource.
  ///
  /// In en, this message translates to:
  /// **'Audio Source'**
  String get audioSource;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @ragLimit.
  ///
  /// In en, this message translates to:
  /// **'RAG limit'**
  String get ragLimit;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @speechToText.
  ///
  /// In en, this message translates to:
  /// **'Speech\\nto Text'**
  String get speechToText;

  /// No description provided for @voiceChat.
  ///
  /// In en, this message translates to:
  /// **'Voice\\nChat'**
  String get voiceChat;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get textToSpeech;

  /// No description provided for @ttsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text to synthesize…'**
  String get ttsHint;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answerLabel;

  /// No description provided for @fileTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'File Translation'**
  String get fileTranslationTitle;

  /// No description provided for @translateHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Translate project\\nfiles'**
  String get translateHeroTitle;

  /// No description provided for @translateHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create jobs · track progress · download results'**
  String get translateHeroSubtitle;

  /// No description provided for @languageExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. en'**
  String get languageExample;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @chooseSupportedFileInstruction.
  ///
  /// In en, this message translates to:
  /// **'Choose a supported file and upload it to project {id}.'**
  String chooseSupportedFileInstruction(int id);

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noFileSelectedYet.
  ///
  /// In en, this message translates to:
  /// **'No file selected yet.'**
  String get noFileSelectedYet;

  /// No description provided for @fileIdLabel.
  ///
  /// In en, this message translates to:
  /// **'File ID'**
  String get fileIdLabel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @statusLog.
  ///
  /// In en, this message translates to:
  /// **'STATUS LOG'**
  String get statusLog;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get noActivityYet;

  /// No description provided for @actionsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Actions will appear here with timestamps.'**
  String get actionsWillAppear;

  /// No description provided for @debugInfo.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// No description provided for @fullPrompt.
  ///
  /// In en, this message translates to:
  /// **'Full Prompt'**
  String get fullPrompt;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @chatHistoryCopied.
  ///
  /// In en, this message translates to:
  /// **'Chat history copied to clipboard.'**
  String get chatHistoryCopied;

  /// No description provided for @dotSeparator.
  ///
  /// In en, this message translates to:
  /// **'·'**
  String get dotSeparator;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recording;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get tapToRecord;

  /// No description provided for @pressStopWhenDone.
  ///
  /// In en, this message translates to:
  /// **'Press stop when done'**
  String get pressStopWhenDone;

  /// No description provided for @orPickAnAudioFileBelow.
  ///
  /// In en, this message translates to:
  /// **'Or pick an audio file below'**
  String get orPickAnAudioFileBelow;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playLastVoiceReplyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play last voice-chat reply only'**
  String get playLastVoiceReplyTooltip;

  /// No description provided for @searchKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Search Knowledge'**
  String get searchKnowledge;

  /// No description provided for @searchRunAgainstProject.
  ///
  /// In en, this message translates to:
  /// **'Run semantic search against the indexed chunks in project {id}.'**
  String searchRunAgainstProject(int id);

  /// No description provided for @searchQuery.
  ///
  /// In en, this message translates to:
  /// **'Search query'**
  String get searchQuery;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Find relevant chunks or concepts…'**
  String get searchHint;

  /// No description provided for @resultLimit.
  ///
  /// In en, this message translates to:
  /// **'Result limit'**
  String get resultLimit;

  /// No description provided for @rangeLimit.
  ///
  /// In en, this message translates to:
  /// **'Range: {min}–{max}'**
  String rangeLimit(Object min, Object max);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @askAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAi;

  /// No description provided for @askQuestionAboutProject.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about the indexed knowledge in project {id}.'**
  String askQuestionAboutProject(int id);

  /// No description provided for @yourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get yourQuestion;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your uploaded knowledge…'**
  String get askHint;

  /// No description provided for @retrievedChunksLimit.
  ///
  /// In en, this message translates to:
  /// **'Retrieved chunks limit'**
  String get retrievedChunksLimit;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @ask.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get ask;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResultsTitle;

  /// No description provided for @noMatchingChunks.
  ///
  /// In en, this message translates to:
  /// **'No matching chunks were returned.'**
  String get noMatchingChunks;

  /// No description provided for @resultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s) for \"{query}\".'**
  String resultsForQuery(Object count, Object query);

  /// No description provided for @ms.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String ms(Object ms);

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @createJob.
  ///
  /// In en, this message translates to:
  /// **'Create Job'**
  String get createJob;

  /// No description provided for @submitTranslationRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit a translation request for a file in project {id}.'**
  String submitTranslationRequest(int id);

  /// No description provided for @fileId.
  ///
  /// In en, this message translates to:
  /// **'File ID'**
  String get fileId;

  /// No description provided for @createdJob.
  ///
  /// In en, this message translates to:
  /// **'Created job'**
  String get createdJob;

  /// No description provided for @translationStatus.
  ///
  /// In en, this message translates to:
  /// **'Translation Status'**
  String get translationStatus;

  /// No description provided for @trackLatestTranslation.
  ///
  /// In en, this message translates to:
  /// **'We\'ll track the latest translation request for you.'**
  String get trackLatestTranslation;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @lookUpById.
  ///
  /// In en, this message translates to:
  /// **'Look up a different request by ID'**
  String get lookUpById;

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGES'**
  String get languagesLabel;

  /// No description provided for @sourceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Source language'**
  String get sourceLanguage;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get targetLanguage;

  /// No description provided for @updateKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Update Knowledge Base'**
  String get updateKnowledgeBase;

  /// No description provided for @finishPreparingDocument.
  ///
  /// In en, this message translates to:
  /// **'Finish preparing the document first.'**
  String get finishPreparingDocument;

  /// No description provided for @makeDocumentAvailable.
  ///
  /// In en, this message translates to:
  /// **'Makes your prepared document available for search and answers.'**
  String get makeDocumentAvailable;

  /// No description provided for @fullRebuild.
  ///
  /// In en, this message translates to:
  /// **'Full rebuild'**
  String get fullRebuild;

  /// No description provided for @fullRebuildSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rebuilds the knowledge base from scratch (slower).'**
  String get fullRebuildSubtitle;

  /// No description provided for @indexing.
  ///
  /// In en, this message translates to:
  /// **'Indexing…'**
  String get indexing;

  /// No description provided for @updateKnowledgeBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Update knowledge base'**
  String get updateKnowledgeBaseLabel;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creating;

  /// No description provided for @jobCreatedHeader.
  ///
  /// In en, this message translates to:
  /// **'JOB CREATED'**
  String get jobCreatedHeader;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @assetLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get assetLabel;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @refreshNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh now'**
  String get refreshNow;

  /// No description provided for @refreshIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh interval'**
  String get refreshIntervalLabel;

  /// No description provided for @keepUpdatingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Keep updating automatically'**
  String get keepUpdatingAutomatically;

  /// No description provided for @refreshEverySeconds.
  ///
  /// In en, this message translates to:
  /// **'Refresh every {s}s until complete'**
  String refreshEverySeconds(Object s);

  /// No description provided for @prepareDocument.
  ///
  /// In en, this message translates to:
  /// **'Prepare Document'**
  String get prepareDocument;

  /// No description provided for @uploadFirstToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upload a file first to unlock this step.'**
  String get uploadFirstToUnlock;

  /// No description provided for @preparesYourDocument.
  ///
  /// In en, this message translates to:
  /// **'Prepares your document for search and question answering.'**
  String get preparesYourDocument;

  /// No description provided for @replacePreviousPreparation.
  ///
  /// In en, this message translates to:
  /// **'Replace previous preparation'**
  String get replacePreviousPreparation;

  /// No description provided for @replacePreviousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use this if you re-uploaded or changed the file.'**
  String get replacePreviousSubtitle;

  /// No description provided for @chunkSize.
  ///
  /// In en, this message translates to:
  /// **'Chunk size'**
  String get chunkSize;

  /// No description provided for @overlapSize.
  ///
  /// In en, this message translates to:
  /// **'Overlap size'**
  String get overlapSize;

  /// No description provided for @onlyChangeIfKnow.
  ///
  /// In en, this message translates to:
  /// **'Only change these if you know what you\'re optimising for.'**
  String get onlyChangeIfKnow;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparing;

  /// No description provided for @prepareDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Prepare document'**
  String get prepareDocumentLabel;

  /// No description provided for @processingComplete.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING COMPLETE'**
  String get processingComplete;

  /// No description provided for @chunksInserted.
  ///
  /// In en, this message translates to:
  /// **'Chunks inserted'**
  String get chunksInserted;

  /// No description provided for @filesProcessed.
  ///
  /// In en, this message translates to:
  /// **'Files processed'**
  String get filesProcessed;
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
