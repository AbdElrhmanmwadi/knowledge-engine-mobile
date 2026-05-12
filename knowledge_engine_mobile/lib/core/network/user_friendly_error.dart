import 'api_exception.dart';

/// Convert internal/network errors into user-friendly messages.

class UserFriendlyError {
  static String message(Object error, {String? fallback}) {
    if (error is ApiException) {
      return _fromApiException(error);
    }

    final asString = error.toString();
    if (asString.trim().isNotEmpty) {
      return fallback ?? 'Something went wrong. Please try again.';
    }

    return fallback ?? 'Something went wrong. Please try again.';
  }

  static String _fromApiException(ApiException e) {
    final code = (e.code ?? '').toUpperCase();
    final message = e.message.toLowerCase();

    if (code == 'NETWORK_ERROR' || message.contains('network error')) {
      return 'Couldn’t reach the server. Check your connection and try again.';
    }
    if (code == 'TIMEOUT' || message.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }
    if (code == 'PARSE_ERROR') {
      return 'We received an unexpected response. Please try again.';
    }

    // Status-code-ish strings sometimes become codes.
    if (code == '400') {
      return 'That request looks invalid. Please check and try again.';
    }
    if (code == '401' || code == '403') {
      return 'You don’t have permission to do that.';
    }
    if (code == '404') {
      return 'We couldn’t find what you requested.';
    }
    if (code == '500') {
      return 'Server error. Please try again in a moment.';
    }

    
    final raw = e.message.trim();
    if (raw.isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    if (raw.length <= 80 && !_looksTooTechnical(raw)) {
      return raw;
    }

    return 'Something went wrong. Please try again.';
  }

  static bool _looksTooTechnical(String text) {
    final t = text.toLowerCase();
    return t.contains('exception') ||
        t.contains('trace') ||
        t.contains('dio') ||
        t.contains('stack') ||
        t.contains('json') ||
        t.contains('api');
  }
}

