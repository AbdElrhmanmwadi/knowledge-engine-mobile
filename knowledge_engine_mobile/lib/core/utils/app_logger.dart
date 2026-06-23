import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight, dependency-free logger built on `dart:developer`.
///
/// Routes through `developer.log` so messages show up structured in the
/// DevTools logging view (with level, name and stack traces) instead of raw
/// `print` output. Everything below [error] is suppressed in release builds so
/// we never leak request/response bodies to production logs.
class AppLogger {
  const AppLogger._();

  /// Verbose, debug-only message (e.g. HTTP request/response dumps).
  static void debug(String message, {String name = 'app'}) {
    if (!kDebugMode) return;
    developer.log(message, name: name, level: 500);
  }

  /// Informational message worth keeping in debug builds.
  static void info(String message, {String name = 'app'}) {
    if (!kDebugMode) return;
    developer.log(message, name: name, level: 800);
  }

  /// Warning — surfaced in debug builds only.
  static void warning(String message, {String name = 'app'}) {
    if (!kDebugMode) return;
    developer.log(message, name: name, level: 900);
  }

  /// Error — always logged (including release) but kept terse. Pass the
  /// [error] and [stackTrace] so they are attached for crash diagnostics.
  static void error(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
