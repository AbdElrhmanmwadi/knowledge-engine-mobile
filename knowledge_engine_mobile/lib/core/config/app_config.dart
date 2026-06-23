import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  /// Backend base URL injected at build time, e.g.
  /// `flutter run --dart-define=API_BASE_URL=https://api.example.com`.
  /// This always takes precedence when set, in both debug and release builds.
  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Production backend. Replace with the real HTTPS domain before shipping a
  /// release build, or supply it via `--dart-define=API_BASE_URL=...`.
  /// Must be HTTPS — plain HTTP is blocked by default on iOS/Android release.
  static const String prodBaseUrl = 'https://api.example.com';

  /// Local dev backend reached from the Android emulator (host loopback).
  static const String devBaseUrl = 'http://10.0.2.2:8000';

  /// Local dev backend reached from the iOS simulator / desktop.
  static const String devBaseUrlIos = 'http://localhost:8000';

  /// Resolves the base URL by priority:
  /// 1. explicit [overrideUrl] (e.g. user-configured server)
  /// 2. compile-time [configuredBaseUrl] (`--dart-define`)
  /// 3. release builds → [prodBaseUrl]
  /// 4. debug builds → platform-appropriate local dev URL
  static String getBaseUrl({String? overrideUrl}) {
    if (overrideUrl != null && overrideUrl.isNotEmpty) {
      return overrideUrl;
    }

    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kReleaseMode) {
      return prodBaseUrl;
    }

    // Debug/profile: talk to a locally running backend.
    if (Platform.isAndroid) {
      return devBaseUrl;
    }
    return devBaseUrlIos;
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
