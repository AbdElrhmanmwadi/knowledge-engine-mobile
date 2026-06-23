// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محرك المعرفة';

  @override
  String get error => 'خطأ';

  @override
  String errorWithMessage(Object message) {
    return 'خطأ: $message';
  }

  @override
  String get goToProjects => 'الانتقال إلى المشاريع';

  @override
  String routeNotFound(Object location) {
    return 'المسار غير موجود: $location';
  }

  @override
  String get language => 'اللغة';

  @override
  String get systemLanguage => 'لغة النظام';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get onboardingOrganizeTitle => 'نظّم المعرفة';

  @override
  String get onboardingOrganizeBody =>
      'أنشئ مساحات مشاريع للمستندات والأسئلة والترجمات والملاحظات الصوتية.';

  @override
  String get onboardingAskTitle => 'اسأل بسياق';

  @override
  String get onboardingAskBody =>
      'ارفع الملفات وفهرسها واحصل على إجابات مبنية على موادك.';

  @override
  String get onboardingFormatsTitle => 'اعمل عبر صيغ متعددة';

  @override
  String get onboardingFormatsBody =>
      'تنقل بين البحث والترجمة والصوت من مساحة عمل واحدة مركزة.';

  @override
  String get openProject => 'فتح مشروع';

  @override
  String get recentProjects => 'المشاريع الأخيرة';

  @override
  String get yourProjects => 'مشاريعك';

  @override
  String get noProjectsYet => 'لا توجد مشاريع بعد.';

  @override
  String get couldNotLoadProjects => 'تعذّر تحميل مشاريعك.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get tapToOpen => 'اضغط للفتح';

  @override
  String get projectId => 'معرّف المشروع';

  @override
  String get projectIdHint => 'مثال: 42';

  @override
  String get clear => 'مسح';

  @override
  String get opening => 'جارٍ الفتح...';

  @override
  String get knowledgeEngineUpper => 'محرك المعرفة';

  @override
  String get projectsHeroTitle => 'مشاريعك\nفي لمحة';

  @override
  String get projectsHeroSubtitle => 'أدخل معرّف مشروع أو اختر مشروعًا حديثًا';

  @override
  String couldNotDeleteProject(int id) {
    return 'تعذر حذف المشروع $id.';
  }

  @override
  String errorLoadingRecentProjects(Object message) {
    return 'حدث خطأ أثناء تحميل المشاريع الأخيرة: $message';
  }

  @override
  String get noRecentProjects => 'لا توجد مشاريع حديثة بعد';

  @override
  String get openProjectAbove => 'افتح مشروعًا أعلاه ليظهر هنا';

  @override
  String projectNumber(int id) {
    return 'المشروع رقم $id';
  }

  @override
  String get tapToOpenSwipeToDelete => 'اضغط للفتح · اسحب للحذف';

  @override
  String get delete => 'حذف';

  @override
  String get documents => 'المستندات';

  @override
  String projectBadge(int id) {
    return 'المشروع $id';
  }

  @override
  String get ready => 'جاهز';

  @override
  String addYourDocuments(Object projectId) {
    return 'أضف$projectIdمستنداتك';
  }

  @override
  String get uploadPrepareIndexSubtitle =>
      'رفع · تجهيز · فهرسة إلى قاعدة المعرفة';

  @override
  String get stepUpload => 'رفع';

  @override
  String get stepPrepare => 'تحضير';

  @override
  String get stepIndex => 'فهرسة';

  @override
  String get chooseFile => 'اختر ملف';

  @override
  String get selectFileToTranslate => 'اختر ملفًا للترجمة';

  @override
  String get noFilesInProject => 'لا توجد ملفات في هذا المشروع بعد.';

  @override
  String get couldNotLoadFiles => 'تعذّر تحميل ملفات هذا المشروع.';

  @override
  String get statusLogCopied => 'تم نسخ سجل الحالة.';

  @override
  String get synthesize => 'تحويل إلى كلام';

  @override
  String get pickAudioFile => 'اختر ملف صوتي';

  @override
  String get copy => 'نسخ';

  @override
  String get promptCopied => 'تم نسخ الموجه إلى الحافظة.';

  @override
  String secondsWithCount(Object s) {
    return '$s ثانية';
  }

  @override
  String get askPageTitle => 'اسأل وابحث';

  @override
  String get askLeftLabel => 'بحث';

  @override
  String get askRightLabel => 'اسأل الذكاء الاصطناعي';

  @override
  String askHeroTitle(Object projectId) {
    return 'ابحث واسأل عبر$projectIdمعرفتك';
  }

  @override
  String get askHeroSubtitle => 'ابحث في مستنداتك واحصل على إجابات';

  @override
  String get workspaceTitle => 'مساحة العمل';

  @override
  String get dashboardPrompt => 'ماذا تريد أن تفعل؟';

  @override
  String get featureDocumentsDesc => 'رفع وفهرسة الملفات';

  @override
  String get featureAskDesc => 'ابحث واحصل على إجابات';

  @override
  String get featureVoiceTitle => 'الصوت';

  @override
  String get featureVoiceDesc => 'تحدث، نسخ، استمع';

  @override
  String get featureTranslateDesc => 'ترجم وحمل';

  @override
  String projectReadyTitle(Object projectId) {
    return 'مشروعك$projectIdجاهز';
  }

  @override
  String get projectReadySubtitle => 'اختر ما تريد فعله بعد.';

  @override
  String get voiceTitle => 'استوديو الصوت';

  @override
  String get micAccessOff =>
      'إمكانية استخدام الميكروفون متوقفة. فعّلها في إعدادات النظام.';

  @override
  String get audioSource => 'مصدر الصوت';

  @override
  String get settings => 'الإعدادات';

  @override
  String get ragLimit => 'عدد المصادر المستخدمة';

  @override
  String get actions => 'الإجراءات';

  @override
  String speechToText(Object projectId) {
    return 'النص$projectIdمن الكلام';
  }

  @override
  String voiceChat(Object projectId) {
    return 'دردشة$projectIdصوتية';
  }

  @override
  String get textToSpeech => 'نص إلى كلام';

  @override
  String get ttsHint => 'أدخل نصًا للتوليد…';

  @override
  String get transcript => 'النص';

  @override
  String get answerLabel => 'الإجابة';

  @override
  String get fileTranslationTitle => 'ترجمة الملفات';

  @override
  String translateHeroTitle(Object projectId) {
    return 'ترجم$projectIdملفات المشروع';
  }

  @override
  String get translateHeroSubtitle =>
      'إنشاء مهام · تتبع التقدّم · تنزيل النتائج';

  @override
  String get languageExample => 'مثال: en';

  @override
  String get uploadFile => 'رفع الملف';

  @override
  String chooseSupportedFileInstruction(int id) {
    return 'اختر ملفًا مدعومًا وارفعه إلى المشروع $id.';
  }

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get upload => 'رفع';

  @override
  String get noFileSelectedYet => 'لم يتم اختيار ملف بعد.';

  @override
  String get fileIdLabel => 'معرّف الملف';

  @override
  String get done => 'تم';

  @override
  String get statusLog => 'سجل الحالة';

  @override
  String get noActivityYet => 'لا توجد نشاطات بعد.';

  @override
  String get actionsWillAppear => 'ستظهر الإجراءات هنا مع الطوابع الزمنية.';

  @override
  String get debugInfo => 'معلومات التصحيح';

  @override
  String get fullPrompt => 'النص الكامل';

  @override
  String get chatHistory => 'سجل الدردشة';

  @override
  String get chatHistoryCopied => 'تم نسخ سجل الدردشة إلى الحافظة.';

  @override
  String get dotSeparator => '·';

  @override
  String get recording => 'جارٍ التسجيل…';

  @override
  String get tapToRecord => 'انقر للتسجيل';

  @override
  String get pressStopWhenDone => 'اضغط إيقاف عند الانتهاء';

  @override
  String get orPickAnAudioFileBelow => 'أو اختر ملف صوتي أدناه';

  @override
  String get stop => 'إيقاف';

  @override
  String get play => 'تشغيل';

  @override
  String get playLastVoiceReplyTooltip => 'تشغيل آخر رد صوتي فقط';

  @override
  String get searchKnowledge => 'بحث المعرفة';

  @override
  String searchRunAgainstProject(int id) {
    return 'ابحث في مستندات المشروع $id.';
  }

  @override
  String get searchQuery => 'استعلام البحث';

  @override
  String get searchHint => 'ابحث عن موضوع أو كلمة…';

  @override
  String get resultLimit => 'حد النتائج';

  @override
  String rangeLimit(Object min, Object max) {
    return 'النطاق: $min–$max';
  }

  @override
  String get search => 'بحث';

  @override
  String get searching => 'جارٍ البحث…';

  @override
  String get askAi => 'اسأل الذكاء الاصطناعي';

  @override
  String askQuestionAboutProject(int id) {
    return 'اطرح سؤالًا عن مستنداتك في المشروع $id.';
  }

  @override
  String get yourQuestion => 'سؤالك';

  @override
  String get askHint => 'اطرح أي شيء عن معرفتك المرفوعة…';

  @override
  String get retrievedChunksLimit => 'عدد المصادر المستخدمة';

  @override
  String get thinking => 'جارٍ التفكير…';

  @override
  String get ask => 'اسأل';

  @override
  String get searchResultsTitle => 'نتائج البحث';

  @override
  String get noMatchingChunks => 'لا توجد نتائج مطابقة.';

  @override
  String resultsForQuery(Object count, Object query) {
    return '$count نتيجة لـ \"$query\".';
  }

  @override
  String ms(Object ms) {
    return '$ms مل';
  }

  @override
  String get hideDetails => 'إخفاء التفاصيل';

  @override
  String get showDetails => 'عرض التفاصيل';

  @override
  String get metadata => 'البيانات الوصفية';

  @override
  String get createJob => 'إنشاء مهمة';

  @override
  String submitTranslationRequest(int id) {
    return 'أرسل طلب ترجمة لملف في المشروع $id.';
  }

  @override
  String get fileId => 'معرّف الملف';

  @override
  String get createdJob => 'المهمة المنشأة';

  @override
  String get translationStatus => 'حالة الترجمة';

  @override
  String get trackLatestTranslation => 'سنُتابع أحدث طلب ترجمة لك.';

  @override
  String get advanced => 'متقدم';

  @override
  String get lookUpById => 'ابحث عن طلب مختلف بواسطة المعرّف';

  @override
  String get languagesLabel => 'اللغات';

  @override
  String get sourceLanguage => 'لغة المصدر';

  @override
  String get targetLanguage => 'لغة الهدف';

  @override
  String get updateKnowledgeBase => 'تحديث قاعدة المعرفة';

  @override
  String get finishPreparingDocument => 'انهِ تحضير المستند أولًا.';

  @override
  String get makeDocumentAvailable =>
      'يجعل المستند المُعد متاحًا للبحث والإجابات.';

  @override
  String get fullRebuild => 'إعادة بناء كاملة';

  @override
  String get fullRebuildSubtitle => 'يعيد بناء قاعدة المعرفة من الصفر (أبطأ).';

  @override
  String get indexing => 'جارٍ الفهرسة…';

  @override
  String get updateKnowledgeBaseLabel => 'تحديث قاعدة المعرفة';

  @override
  String get creating => 'جارٍ الإنشاء…';

  @override
  String get jobCreatedHeader => 'تم إنشاء المهمة';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get assetLabel => 'الموارد';

  @override
  String get routeLabel => 'المسار';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get checking => 'جارٍ التحقق…';

  @override
  String get refreshNow => 'تحديث الآن';

  @override
  String get refreshIntervalLabel => 'فاصل التحديث';

  @override
  String get keepUpdatingAutomatically => 'استمر بالتحديث تلقائيًا';

  @override
  String refreshEverySeconds(Object s) {
    return 'التحديث كل $s ثانية حتى الاكتمال';
  }

  @override
  String get prepareDocument => 'تحضير المستند';

  @override
  String get uploadFirstToUnlock => 'ارفع ملفًا أولًا لفتح هذه الخطوة.';

  @override
  String get preparesYourDocument => 'يُعد مستندك للبحث والإجابة.';

  @override
  String get replacePreviousPreparation => 'استبدال التحضير السابق';

  @override
  String get replacePreviousSubtitle =>
      'استخدم هذا إذا قمت بإعادة رفع الملف أو تغييره.';

  @override
  String get chunkSize => 'حجم المقطع';

  @override
  String get overlapSize => 'تداخل المقاطع';

  @override
  String get onlyChangeIfKnow =>
      'غيّر هذه القيم فقط إذا عرفت ما الذي تحسّن من أجله.';

  @override
  String get preparing => 'جارٍ التحضير…';

  @override
  String get prepareDocumentLabel => 'تحضير المستند';

  @override
  String get processingComplete => 'اكتمل المعالجة';

  @override
  String get chunksInserted => 'المقاطع المضافة';

  @override
  String get filesProcessed => 'الملفات المعالجة';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة إلى مشاريعك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول…';

  @override
  String get forgotPasswordQuestion => 'هل نسيت كلمة المرور؟';

  @override
  String get noAccountCreateOne => 'ليس لديك حساب؟ أنشئ حسابًا';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'أنشئ حسابك في محرك المعرفة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب…';

  @override
  String get alreadyHaveAccountSignIn => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get checkYourEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get checkYourEmailSubtitle => 'خطوة أخيرة لتفعيل حسابك';

  @override
  String checkYourEmailBody(Object email) {
    return 'أرسلنا رابط تفعيل إلى $email. افتحه لتفعيل حسابك ثم سجّل الدخول.';
  }

  @override
  String get backToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'سنرسل لك رابطًا لإعادة تعيينها عبر البريد';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get sending => 'جارٍ الإرسال…';

  @override
  String get resetEmailSentGeneric =>
      'إذا كان هناك حساب بهذا البريد الإلكتروني، فقد تم إرسال رابط إعادة تعيين كلمة المرور.';

  @override
  String resendInSeconds(Object s) {
    return 'إعادة الإرسال خلال $s ث';
  }

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle => 'اختر كلمة مرور جديدة لحسابك';

  @override
  String get resetTokenLabel => 'رمز إعادة التعيين';

  @override
  String get resetTokenHint => 'الصق الرمز من رابط البريد الإلكتروني';

  @override
  String get resetTokenRequired =>
      'الصق رمز إعادة التعيين من البريد الإلكتروني';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get resetting => 'جارٍ إعادة التعيين…';

  @override
  String get passwordChangedTitle => 'تم تغيير كلمة المرور';

  @override
  String get passwordChangedSubtitle => 'سجّل الدخول بكلمة المرور الجديدة';

  @override
  String get requestNewLink => 'اطلب رابطًا جديدًا';

  @override
  String get verifyEmailTitle => 'تأكيد البريد الإلكتروني';

  @override
  String get verifyEmailSubtitle => 'أكّد بريدك الإلكتروني لتفعيل حسابك';

  @override
  String get verificationTokenLabel => 'رمز التفعيل';

  @override
  String get verificationTokenHint => 'الصق الرمز من رابط البريد الإلكتروني';

  @override
  String get verificationTokenRequired =>
      'الصق رمز التفعيل من البريد الإلكتروني';

  @override
  String get verifyEmailButton => 'تأكيد البريد';

  @override
  String get verifying => 'جارٍ التحقق…';

  @override
  String get emailVerifiedTitle => 'تم تأكيد البريد';

  @override
  String get emailVerifiedSubtitle => 'حسابك جاهز — سجّل الدخول للمتابعة';

  @override
  String get authEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get authEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get authPasswordRequired => 'أدخل كلمة المرور';

  @override
  String get authUsernameRequired => 'أدخل اسم المستخدم';

  @override
  String get authPasswordRule => 'يجب أن تكون كلمة المرور بين 8 و128 حرفًا';

  @override
  String get authErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailNotVerified =>
      'لم يتم تأكيد بريدك الإلكتروني بعد. تحقق من صندوق الوارد لرابط التفعيل.';

  @override
  String get authErrorGoogleAccount =>
      'هذا الحساب يستخدم تسجيل الدخول عبر Google. يرجى تسجيل الدخول باستخدام Google.';

  @override
  String get authErrorResetLinkExpired =>
      'انتهت صلاحية هذا الرابط. اطلب رابطًا جديدًا.';

  @override
  String get authErrorResetLinkInvalid =>
      'هذا الرابط غير صالح أو تم استخدامه من قبل. اطلب رابطًا جديدًا.';

  @override
  String get authErrorNetwork =>
      'تعذر الوصول إلى الخادم. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get authErrorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get agentTitle => 'الوكيل';

  @override
  String get agentSubtitle => 'إجابات تحادثية مع ذاكرة';

  @override
  String get agentInputHint => 'راسل الوكيل…';

  @override
  String get agentSend => 'إرسال';

  @override
  String get agentNewChat => 'محادثة جديدة';

  @override
  String get agentHistory => 'سجل المحادثات';

  @override
  String get agentNoSessions => 'لا توجد محادثات بعد';

  @override
  String get agentEmptyTitle => 'اسأل الوكيل أي شيء';

  @override
  String get agentEmptyBody => 'يجيب من مستندات مشروعك ويتذكر سياق المحادثة.';

  @override
  String get agentThinking => 'يفكّر…';

  @override
  String get agentSources => 'المصادر';

  @override
  String a11yYouMessage(Object message) {
    return 'قلت: $message';
  }

  @override
  String a11yAssistantMessage(Object message) {
    return 'قال المساعد: $message';
  }

  @override
  String a11yAnswer(Object answer) {
    return 'الإجابة: $answer';
  }

  @override
  String get agentUntitledSession => 'محادثة بدون عنوان';

  @override
  String get agentDeleteSession => 'حذف المحادثة';

  @override
  String get agentDeleteSessionBody => 'سيتم حذف هذه المحادثة نهائيًا.';

  @override
  String get featureAgentTitle => 'محادثة الوكيل';

  @override
  String get featureAgentDesc => 'محادثة بذاكرة عبر معرفتك';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى مشاريعك.';

  @override
  String get cancel => 'إلغاء';
}
