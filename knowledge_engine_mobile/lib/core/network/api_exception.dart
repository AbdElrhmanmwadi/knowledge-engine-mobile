/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  ApiException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;

  /// Parse API error response and create exception
  factory ApiException.fromResponse({
    required int statusCode,
    required dynamic responseData,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    String message = 'API Error: $statusCode';
    String? code;

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      // Check for 'message' field
      if (responseData.containsKey('message')) {
        message = responseData['message'] as String;
      }
      // Check for 'error' field
      else if (responseData.containsKey('error')) {
        message = responseData['error'] as String;
      }
      // Check for 'detail' field
      else if (responseData.containsKey('detail')) {
        message = responseData['detail'] as String;
      }

      // Try to get error code
      if (responseData.containsKey('code')) {
        code = responseData['code'] as String;
      }
    } else if (responseData is String) {
      message = responseData;
    }

    return ApiException(
      message: message,
      code: code ?? statusCode.toString(),
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Network error exception
  factory ApiException.networkError({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: 'Network Error: $message',
      code: 'NETWORK_ERROR',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Timeout error exception
  factory ApiException.timeoutError({
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: 'Request timeout. Please check your connection and try again.',
      code: 'TIMEOUT',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Parse error exception
  factory ApiException.parseError({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: 'Failed to parse response: $message',
      code: 'PARSE_ERROR',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Unknown error exception
  factory ApiException.unknownError({
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: 'An unexpected error occurred. Please try again.',
      code: 'UNKNOWN_ERROR',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Validation error exception
  factory ApiException.validationError({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: 'Validation Error: $message',
      code: 'VALIDATION_ERROR',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }

  /// Backend-declared failure while still returning a valid JSON body.
  factory ApiException.backendError({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) {
    return ApiException(
      message: message,
      code: code ?? 'BACKEND_ERROR',
      originalException: originalException,
      stackTrace: stackTrace,
    );
  }
}
