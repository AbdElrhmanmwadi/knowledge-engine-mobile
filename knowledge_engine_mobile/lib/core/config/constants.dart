/// API endpoint constants
class ApiConstants {
  // Base paths
  static const String basePath = '/api/v1';
  static const String dataPath = '/api/v1/data';
  static const String nlpPath = '/api/v1/nlp';
  static const String translatePath = '/translate';

  // Data endpoints
  static String uploadFile(int projectId) => '$dataPath/upload/$projectId';
  static String processFile(int projectId) => '$dataPath/process/$projectId';

  // Index endpoints
  static String pushIndex(int projectId) => '$nlpPath/index/push/$projectId';
  static String getIndexInfo(int projectId) => '$nlpPath/index/info/$projectId';
  static String searchIndex(int projectId) => '$nlpPath/index/search/$projectId';
  static String answerQuestion(int projectId) =>
      '$nlpPath/index/answer/$projectId';

  // Translation endpoints
  static const String createTranslationJob = '$translatePath/file';
  static String getTranslationStatus(String jobId) =>
      '$translatePath/status/$jobId';
}

/// Supported file types for upload
class SupportedFileTypes {
  static const List<String> extensions = [
    '.txt',
    '.pdf',
    '.docx',
    '.csv',
    '.html',
    '.xlsx',
  ];

  static const Map<String, String> mimeTypes = {
    '.txt': 'text/plain',
    '.pdf': 'application/pdf',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.csv': 'text/csv',
    '.html': 'text/html',
    '.xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };

  static bool isSupported(String fileName) {
    return extensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  static String? getMimeType(String fileName) {
    for (var ext in extensions) {
      if (fileName.toLowerCase().endsWith(ext)) {
        return mimeTypes[ext];
      }
    }
    return null;
  }
}

/// Language codes for translation
class LanguageCodes {
  static const Map<String, String> languages = {
    'en': 'English',
    'ar': 'العربية',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
    'ru': 'Русский',
    'ja': '日本語',
    'pt': 'Português',
    'ko': '한국어',
  };

  static const String defaultSourceLanguage = 'en';
  static const String defaultTargetLanguage = 'ar';

  static List<String> getCodes() => languages.keys.toList();

  static String getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'Arabic';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'zh':
        return 'Chinese';
      case 'ru':
        return 'Russian';
      case 'ja':
        return 'Japanese';
      case 'pt':
        return 'Portuguese';
      case 'ko':
        return 'Korean';
      default:
        return languages[code] ?? code.toUpperCase();
    }
  }
}

/// Job status constants
class JobStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';

  static bool isCompleted(String status) =>
      status == completed || status == failed;

  static bool isProcessing(String status) =>
      status == pending || status == processing;
}

/// API response signals
class ApiSignals {
  static const String success = 'success';
  static const String error = 'error';
  static const String warning = 'warning';
  static bool isSuccessSignal(String signal) {
  final normalized = signal.trim().toLowerCase();
  return normalized == success || normalized.endsWith(success); 
}
}

/// Validation constants
class ValidationConstants {
  static const int minProjectId = 1;
  static const int maxProjectId = 999999999;
  static const int minChunkSize = 100;
  static const int maxChunkSize = 5000;
  static const int minOverlapSize = 0;
  static const int maxOverlapSize = 1000;
  static const int minSearchLimit = 1;
  static const int maxSearchLimit = 50;
  static const int minRagLimit = 1;
  static const int maxRagLimit = 20;
}

/// UI constants
class UiConstants {
  static const double minButtonHeight = 48.0;
  static const double minTouchTarget = 48.0;
  static const double cardElevation = 2.0;
  static const double defaultBorderRadius = 8.0;
}

/// Storage keys for SharedPreferences
class StorageKeys {
  static const String recentProjects = 'recent_projects';
  static const String lastBackendUrl = 'last_backend_url';
  static const String lastTargetLanguage = 'last_target_language';
  static const String lastSourceLanguage = 'last_source_language';

  static String latestFileIdForProject(int projectId) =>
      'latest_file_id_project_$projectId';
}
