import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../utils/app_logger.dart';

/// Retries transient failures (network drops, timeouts, gateway 5xx) with
/// exponential backoff and jitter, so a brief connectivity blip doesn't surface
/// as a hard error to the user.
///
/// Safety rules (to avoid duplicate side-effects):
/// - **GET** requests are retried on any transient error.
/// - **Non-idempotent** requests (POST/PUT/PATCH/DELETE) are retried only on
///   connection errors / connect-timeouts, where the request almost certainly
///   never reached the server. They are NOT retried on receive-timeouts or 5xx,
///   since the server may have already processed them.
///
/// Auth (401) refresh is handled separately by `AuthInterceptor`; this
/// interceptor never retries 4xx responses or cancelled requests.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio Function() dioProvider,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 300),
  }) : _dioProvider = dioProvider;

  static const String _attemptKey = 'retry_attempt';

  final Dio Function() _dioProvider;
  final int maxRetries;
  final Duration baseDelay;
  final Random _random = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    final cancelled = options.cancelToken?.isCancelled ?? false;

    if (cancelled || attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // Re-dispatch a single attempt. Because `fetch` runs the full interceptor
    // chain again, a repeated failure re-enters this handler and retries using
    // the shared, incremented counter — so no manual loop is needed.
    final nextAttempt = attempt + 1;
    options.extra[_attemptKey] = nextAttempt;
    final delay = _backoff(nextAttempt);
    AppLogger.debug(
      'Retry $nextAttempt/$maxRetries for ${options.method} ${options.path} '
      'in ${delay.inMilliseconds}ms',
      name: 'http',
    );
    await Future<void>.delayed(delay);

    if (options.cancelToken?.isCancelled ?? false) {
      handler.next(err);
      return;
    }

    try {
      final response = await _dioProvider().fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    // Never retry a request the caller cancelled.
    if (err.type == DioExceptionType.cancel) return false;

    final isConnectionIssue = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;
    final isReceiveTimeout = err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
    final status = err.response?.statusCode;
    final isGatewayError =
        status == 502 || status == 503 || status == 504;

    final isIdempotent = err.requestOptions.method.toUpperCase() == 'GET';

    if (isIdempotent) {
      return isConnectionIssue || isReceiveTimeout || isGatewayError;
    }
    // Non-idempotent: only retry when the request likely never landed.
    return isConnectionIssue;
  }

  /// Exponential backoff (baseDelay * 2^(attempt-1)) with up to 30% jitter to
  /// avoid synchronized retry storms.
  Duration _backoff(int attempt) {
    final exp = baseDelay.inMilliseconds * (1 << (attempt - 1));
    final jitter = (exp * 0.3 * _random.nextDouble()).round();
    return Duration(milliseconds: exp + jitter);
  }
}
