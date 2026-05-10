import 'dart:io';

class AppConfig {
  /// Backend base URL configuration
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String prodBaseUrl = 'http://localhost:8000';
  static const String devBaseUrl = 'http://10.0.2.2:8000';

  /// Get the current base URL based on platform and environment
  static String getBaseUrl({String? overrideUrl}) {
    if (overrideUrl != null && overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    // For Android emulator, use 10.0.2.2; for physical device, use localhost
    if (Platform.isAndroid) {
      return devBaseUrl;
    } else if (Platform.isIOS) {
      return 'http://localhost:8000';
    }

    return defaultBaseUrl;
  }

  /// API request timeout in seconds
  static const int requestTimeout = 60;

  /// File upload timeout in seconds
  static const int uploadTimeout = 120;

  /// Default values for file processing
  static const int defaultChunkSize = 512;
  static const int defaultOverlapSize = 50;

  /// Default values for search and RAG
  static const int defaultSearchLimit = 10;
  static const int defaultRagLimit = 5;

  /// Translation job polling interval in seconds
  static const int translationPollInterval = 5;

  /// Maximum items to store in recent projects
  static const int maxRecentProjects = 10;
}
