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
  String get yourProjects => 'Your Projects';

  @override
  String get noProjectsYet => 'No projects yet.';

  @override
  String get couldNotLoadProjects => 'Couldn’t load your projects.';

  @override
  String get retry => 'Retry';

  @override
  String get tapToOpen => 'Tap to open';

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

  @override
  String get documents => 'Documents';

  @override
  String projectBadge(int id) {
    return 'PROJECT $id';
  }

  @override
  String get ready => 'READY';

  @override
  String addYourDocuments(Object projectId) {
    return 'Add your${projectId}documents';
  }

  @override
  String get uploadPrepareIndexSubtitle =>
      'Upload · prepare · index into knowledge base';

  @override
  String get stepUpload => 'Upload';

  @override
  String get stepPrepare => 'Prepare';

  @override
  String get stepIndex => 'Index';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get selectFileToTranslate => 'Select a file to translate';

  @override
  String get noFilesInProject => 'No files in this project yet.';

  @override
  String get couldNotLoadFiles => 'Couldn’t load this project’s files.';

  @override
  String get statusLogCopied => 'Status log copied.';

  @override
  String get synthesize => 'Synthesize';

  @override
  String get pickAudioFile => 'Pick audio file';

  @override
  String get copy => 'Copy';

  @override
  String get promptCopied => 'Prompt copied to clipboard.';

  @override
  String secondsWithCount(Object s) {
    return '$s seconds';
  }

  @override
  String get askPageTitle => 'Ask & Search';

  @override
  String get askLeftLabel => 'Search';

  @override
  String get askRightLabel => 'Ask AI';

  @override
  String askHeroTitle(Object projectId) {
    return 'Search & ask across${projectId}your knowledge';
  }

  @override
  String get askHeroSubtitle => 'Search your documents and get answers';

  @override
  String get workspaceTitle => 'Workspace';

  @override
  String get dashboardPrompt => 'What would you like to do?';

  @override
  String get featureDocumentsDesc => 'Upload & index files';

  @override
  String get featureAskDesc => 'Search & get answers';

  @override
  String get featureVoiceTitle => 'Voice';

  @override
  String get featureVoiceDesc => 'Speak, transcribe, listen';

  @override
  String get featureTranslateDesc => 'Translate & download';

  @override
  String projectReadyTitle(Object projectId) {
    return 'Your project${projectId}is ready';
  }

  @override
  String get projectReadySubtitle => 'Pick what you want to do next.';

  @override
  String get voiceTitle => 'Voice Studio';

  @override
  String get micAccessOff =>
      'Microphone access is off. Enable it in system settings.';

  @override
  String get audioSource => 'Audio Source';

  @override
  String get settings => 'Settings';

  @override
  String get ragLimit => 'Sources to use';

  @override
  String get actions => 'Actions';

  @override
  String speechToText(Object projectId) {
    return 'Speech${projectId}to Text';
  }

  @override
  String voiceChat(Object projectId) {
    return 'Voice${projectId}Chat';
  }

  @override
  String get textToSpeech => 'Text to Speech';

  @override
  String get ttsHint => 'Enter text to synthesize…';

  @override
  String get transcript => 'Transcript';

  @override
  String get answerLabel => 'Answer';

  @override
  String get fileTranslationTitle => 'File Translation';

  @override
  String translateHeroTitle(Object projectId) {
    return 'Translate project${projectId}files';
  }

  @override
  String get translateHeroSubtitle =>
      'Create jobs · track progress · download results';

  @override
  String get languageExample => 'e.g. en';

  @override
  String get uploadFile => 'Upload File';

  @override
  String chooseSupportedFileInstruction(int id) {
    return 'Choose a supported file and upload it to project $id.';
  }

  @override
  String get uploading => 'Uploading…';

  @override
  String get upload => 'Upload';

  @override
  String get noFileSelectedYet => 'No file selected yet.';

  @override
  String get fileIdLabel => 'File ID';

  @override
  String get done => 'Done';

  @override
  String get statusLog => 'STATUS LOG';

  @override
  String get noActivityYet => 'No activity yet.';

  @override
  String get actionsWillAppear => 'Actions will appear here with timestamps.';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get fullPrompt => 'Full Prompt';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get chatHistoryCopied => 'Chat history copied to clipboard.';

  @override
  String get dotSeparator => '·';

  @override
  String get recording => 'Recording…';

  @override
  String get tapToRecord => 'Tap to record';

  @override
  String get pressStopWhenDone => 'Press stop when done';

  @override
  String get orPickAnAudioFileBelow => 'Or pick an audio file below';

  @override
  String get stop => 'Stop';

  @override
  String get play => 'Play';

  @override
  String get playLastVoiceReplyTooltip => 'Play last voice-chat reply only';

  @override
  String get searchKnowledge => 'Search Knowledge';

  @override
  String searchRunAgainstProject(int id) {
    return 'Search across the documents in project $id.';
  }

  @override
  String get searchQuery => 'Search query';

  @override
  String get searchHint => 'Find a topic or keyword…';

  @override
  String get resultLimit => 'Result limit';

  @override
  String rangeLimit(Object min, Object max) {
    return 'Range: $min–$max';
  }

  @override
  String get search => 'Search';

  @override
  String get searching => 'Searching…';

  @override
  String get askAi => 'Ask AI';

  @override
  String askQuestionAboutProject(int id) {
    return 'Ask a question about your documents in project $id.';
  }

  @override
  String get yourQuestion => 'Your question';

  @override
  String get askHint => 'Ask anything about your uploaded knowledge…';

  @override
  String get retrievedChunksLimit => 'Sources to use';

  @override
  String get thinking => 'Thinking…';

  @override
  String get ask => 'Ask';

  @override
  String get searchResultsTitle => 'Search Results';

  @override
  String get noMatchingChunks => 'No matching results found.';

  @override
  String resultsForQuery(Object count, Object query) {
    return '$count result(s) for \"$query\".';
  }

  @override
  String ms(Object ms) {
    return '$ms ms';
  }

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get metadata => 'Metadata';

  @override
  String get createJob => 'Create Job';

  @override
  String submitTranslationRequest(int id) {
    return 'Submit a translation request for a file in project $id.';
  }

  @override
  String get fileId => 'File ID';

  @override
  String get createdJob => 'Created job';

  @override
  String get translationStatus => 'Translation Status';

  @override
  String get trackLatestTranslation =>
      'We\'ll track the latest translation request for you.';

  @override
  String get advanced => 'Advanced';

  @override
  String get lookUpById => 'Look up a different request by ID';

  @override
  String get languagesLabel => 'LANGUAGES';

  @override
  String get sourceLanguage => 'Source language';

  @override
  String get targetLanguage => 'Target language';

  @override
  String get updateKnowledgeBase => 'Update Knowledge Base';

  @override
  String get finishPreparingDocument => 'Finish preparing the document first.';

  @override
  String get makeDocumentAvailable =>
      'Makes your prepared document available for search and answers.';

  @override
  String get fullRebuild => 'Full rebuild';

  @override
  String get fullRebuildSubtitle =>
      'Rebuilds the knowledge base from scratch (slower).';

  @override
  String get indexing => 'Indexing…';

  @override
  String get updateKnowledgeBaseLabel => 'Update knowledge base';

  @override
  String get creating => 'Creating…';

  @override
  String get jobCreatedHeader => 'JOB CREATED';

  @override
  String get statusLabel => 'Status';

  @override
  String get assetLabel => 'Asset';

  @override
  String get routeLabel => 'Route';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get checking => 'Checking…';

  @override
  String get refreshNow => 'Refresh now';

  @override
  String get refreshIntervalLabel => 'Refresh interval';

  @override
  String get keepUpdatingAutomatically => 'Keep updating automatically';

  @override
  String refreshEverySeconds(Object s) {
    return 'Refresh every ${s}s until complete';
  }

  @override
  String get prepareDocument => 'Prepare Document';

  @override
  String get uploadFirstToUnlock => 'Upload a file first to unlock this step.';

  @override
  String get preparesYourDocument =>
      'Prepares your document for search and question answering.';

  @override
  String get replacePreviousPreparation => 'Replace previous preparation';

  @override
  String get replacePreviousSubtitle =>
      'Use this if you re-uploaded or changed the file.';

  @override
  String get chunkSize => 'Segment size';

  @override
  String get overlapSize => 'Segment overlap';

  @override
  String get onlyChangeIfKnow =>
      'Only change these if you know what you\'re optimising for.';

  @override
  String get preparing => 'Preparing…';

  @override
  String get prepareDocumentLabel => 'Prepare document';

  @override
  String get processingComplete => 'PROCESSING COMPLETE';

  @override
  String get chunksInserted => 'Sections added';

  @override
  String get filesProcessed => 'Files processed';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue to your projects';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get noAccountCreateOne => 'Don\'t have an account? Create one';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Set up your Knowledge Engine account';

  @override
  String get username => 'Username';

  @override
  String get createAccount => 'Create account';

  @override
  String get creatingAccount => 'Creating account…';

  @override
  String get alreadyHaveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get checkYourEmailTitle => 'Check your email';

  @override
  String get checkYourEmailSubtitle => 'One more step to activate your account';

  @override
  String checkYourEmailBody(Object email) {
    return 'We sent a verification link to $email. Open it to activate your account, then sign in.';
  }

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle => 'We\'ll email you a link to reset it';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get sending => 'Sending…';

  @override
  String get resetEmailSentGeneric =>
      'If an account with that email exists, a password reset link has been sent.';

  @override
  String resendInSeconds(Object s) {
    return 'Resend in ${s}s';
  }

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordSubtitle => 'Choose a new password for your account';

  @override
  String get resetTokenLabel => 'Reset token';

  @override
  String get resetTokenHint => 'Paste the token from the email link';

  @override
  String get resetTokenRequired => 'Paste the reset token from the email';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get resetting => 'Resetting…';

  @override
  String get passwordChangedTitle => 'Password changed';

  @override
  String get passwordChangedSubtitle => 'Sign in with your new password';

  @override
  String get requestNewLink => 'Request a new link';

  @override
  String get verifyEmailTitle => 'Verify email';

  @override
  String get verifyEmailSubtitle =>
      'Confirm your email address to activate your account';

  @override
  String get verificationTokenLabel => 'Verification token';

  @override
  String get verificationTokenHint => 'Paste the token from the email link';

  @override
  String get verificationTokenRequired =>
      'Paste the verification token from the email';

  @override
  String get verifyEmailButton => 'Verify email';

  @override
  String get verifying => 'Verifying…';

  @override
  String get emailVerifiedTitle => 'Email verified';

  @override
  String get emailVerifiedSubtitle =>
      'Your account is ready — sign in to continue';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Enter a valid email address';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authUsernameRequired => 'Enter a username';

  @override
  String get authPasswordRule => 'Password must be 8–128 characters';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorEmailNotVerified =>
      'Your email is not verified yet. Check your inbox for the verification link.';

  @override
  String get authErrorGoogleAccount =>
      'This account uses Google sign-in. Please sign in with Google.';

  @override
  String get authErrorResetLinkExpired =>
      'This link has expired. Request a new one.';

  @override
  String get authErrorResetLinkInvalid =>
      'This link is invalid or was already used. Request a new one.';

  @override
  String get authErrorNetwork =>
      'Couldn\'t reach the server. Check your connection and try again.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get agentTitle => 'Agent';

  @override
  String get agentSubtitle => 'Conversational answers with memory';

  @override
  String get agentInputHint => 'Message the agent…';

  @override
  String get agentSend => 'Send';

  @override
  String get agentNewChat => 'New chat';

  @override
  String get agentHistory => 'Chat history';

  @override
  String get agentNoSessions => 'No conversations yet';

  @override
  String get agentEmptyTitle => 'Ask the agent anything';

  @override
  String get agentEmptyBody =>
      'It answers from your project’s documents and remembers the conversation.';

  @override
  String get agentThinking => 'Thinking…';

  @override
  String get agentSources => 'Sources';

  @override
  String get agentUntitledSession => 'Untitled chat';

  @override
  String get agentDeleteSession => 'Delete conversation';

  @override
  String get agentDeleteSessionBody =>
      'This conversation will be permanently deleted.';

  @override
  String get featureAgentTitle => 'Agent chat';

  @override
  String get featureAgentDesc => 'Chat with memory across your knowledge';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody =>
      'You\'ll need to sign in again to access your projects.';

  @override
  String get cancel => 'Cancel';
}
