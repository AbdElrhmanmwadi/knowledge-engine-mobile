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
}
