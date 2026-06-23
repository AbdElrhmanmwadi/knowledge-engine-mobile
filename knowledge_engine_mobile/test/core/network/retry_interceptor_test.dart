import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/core/network/retry_interceptor.dart';

/// One scripted outcome for the fake adapter: either an HTTP status or a
/// thrown [DioException] of a given type.
class _Outcome {
  const _Outcome.status(this.statusCode)
      : throwType = null,
        body = '{}';
  const _Outcome.throws(this.throwType)
      : statusCode = null,
        body = null;

  final int? statusCode;
  final DioExceptionType? throwType;
  final String? body;
}

/// Replays a queue of [_Outcome]s and records how many times it was hit.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.outcomes);

  final List<_Outcome> outcomes;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final outcome =
        outcomes[calls < outcomes.length ? calls : outcomes.length - 1];
    calls++;
    if (outcome.throwType != null) {
      throw DioException(requestOptions: options, type: outcome.throwType!);
    }
    return ResponseBody.fromString(
      outcome.body ?? '{}',
      outcome.statusCode!,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dioProvider: () => dio,
      maxRetries: 3,
      // Keep tests fast — real backoff is 300ms+.
      baseDelay: const Duration(milliseconds: 1),
    ),
  );
  return dio;
}

void main() {
  group('RetryInterceptor', () {
    test('retries a GET on 503 and succeeds once the server recovers', () async {
      final adapter = _FakeAdapter([
        const _Outcome.status(503),
        const _Outcome.status(503),
        const _Outcome.status(200),
      ]);
      final dio = _dioWith(adapter);

      final response = await dio.get<dynamic>('/data');

      expect(response.statusCode, 200);
      expect(adapter.calls, 3); // initial + 2 retries
    });

    test('gives up after maxRetries when the error persists', () async {
      final adapter = _FakeAdapter([const _Outcome.status(503)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/data'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 4); // initial + 3 retries
    });

    test('does not retry a 4xx client error', () async {
      final adapter = _FakeAdapter([const _Outcome.status(400)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/data'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('does not retry a non-idempotent POST on 503', () async {
      final adapter = _FakeAdapter([const _Outcome.status(503)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.post<dynamic>('/data'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('retries a POST on a connection error (request never landed)',
        () async {
      final adapter = _FakeAdapter([
        const _Outcome.throws(DioExceptionType.connectionError),
        const _Outcome.status(200),
      ]);
      final dio = _dioWith(adapter);

      final response = await dio.post<dynamic>('/data');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('does not retry when the request was cancelled', () async {
      final adapter = _FakeAdapter([
        const _Outcome.throws(DioExceptionType.cancel),
        const _Outcome.status(200),
      ]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<dynamic>('/data'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });
  });
}
