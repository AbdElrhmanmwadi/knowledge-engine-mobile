/// API endpoint constants
class ApiConstants {
  // Base paths
  static const String basePath = '/api/v1';
  static const String dataPath = '/api/v1/data';
  static const String nlpPath = '/api/v1/nlp';
  static const String voicePath = '/api/v1/voice';
  static const String translatePath = '/translate';

  // Project endpoints
  static String listProjects({int page = 1, int pageSize = 50}) =>
      '$basePath/projects?page=$page&page_size=$pageSize';

  // Data endpoints
  static String uploadFile(int projectId) => '$dataPath/upload/$projectId';
  static String listProjectFiles(int projectId) => '$dataPath/files/$projectId';
  static String processFile(int projectId) => '$dataPath/process/$projectId';
  static String deleteAllProjectFiles(int projectId) =>
      '$dataPath/delete_all/$projectId';

  // Index endpoints
  static String pushIndex(int projectId) => '$nlpPath/index/push/$projectId';
  static String getIndexInfo(int projectId) => '$nlpPath/index/info/$projectId';
  static String searchIndex(int projectId) => '$nlpPath/index/search/$projectId';
  static String answerQuestion(int projectId) =>
      '$nlpPath/index/answer/$projectId';

  // Agent (conversational RAG) endpoints
  static const String agentPath = '$basePath/agent';
  static String agentChat(int projectId) => '$agentPath/chat/$projectId';
  static String agentSessions(int projectId) => '$agentPath/sessions/$projectId';
  static String agentSession(int projectId, int sessionId) =>
      '$agentPath/sessions/$projectId/$sessionId';

  // Voice endpoints
  static const String speechToText = '$voicePath/stt';
  static const String textToSpeech = '$voicePath/tts';
  static String voiceChat(int projectId) => '$voicePath/chat/$projectId';

  // Translation endpoints
  static const String createTranslationJob = '$translatePath/file';
  static String getTranslationStatus(String jobId) =>
      '$translatePath/status/$jobId';
  static String downloadTranslatedFile(int jobId) =>
      '$translatePath/download/$jobId';
}

/// Authentication endpoint constants (mounted under /auth, not /api/v1)
class AuthConstants {
  static const String authPath = '/auth';

  static const String register = '$authPath/register';
  static const String login = '$authPath/login';
  static const String googleLogin = '$authPath/google';
  static const String verifyEmail = '$authPath/verify-email';
  static const String requestPasswordReset = '$authPath/request-password-reset';
  static const String resetPassword = '$authPath/reset-password';
  static const String refreshToken = '$authPath/refresh';
  static const String logout = '$authPath/logout';

  /// Password rules shared by register and reset-password.
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
}

/// Supported file types for upload
class SupportedFileTypes {
  static const List<String> extensions = [
    '.txt',
    '.md',
    '.pdf',
    '.docx',
    '.csv',
    '.html',
    '.xlsx',
  ];

  static const Map<String, String> mimeTypes = {
    '.txt': 'text/plain',
    '.md': 'text/markdown',
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
  static const int minVoiceChatLimit = 1;
  static const int maxVoiceChatLimit = 200;
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
