import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/core/network/api_exception.dart';

void main() {
  group('ApiException.fromResponse', () {
    test('extracts the "message" field when present', () {
      final ex = ApiException.fromResponse(
        statusCode: 400,
        responseData: {'message': 'Bad input', 'code': 'INVALID'},
      );
      expect(ex.message, 'Bad input');
      expect(ex.code, 'INVALID');
    });

    test('falls back to the "error" field', () {
      final ex = ApiException.fromResponse(
        statusCode: 401,
        responseData: {'error': 'Unauthorized'},
      );
      expect(ex.message, 'Unauthorized');
    });

    test('falls back to the "detail" field (FastAPI style)', () {
      final ex = ApiException.fromResponse(
        statusCode: 422,
        responseData: {'detail': 'Validation failed'},
      );
      expect(ex.message, 'Validation failed');
    });

    test('uses a raw string body directly', () {
      final ex = ApiException.fromResponse(
        statusCode: 500,
        responseData: 'Internal Server Error',
      );
      expect(ex.message, 'Internal Server Error');
    });

    test('defaults code to the status code when none is provided', () {
      final ex = ApiException.fromResponse(
        statusCode: 503,
        responseData: {'message': 'Unavailable'},
      );
      expect(ex.code, '503');
    });

    test('produces a generic message for an unexpected body shape', () {
      final ex = ApiException.fromResponse(
        statusCode: 418,
        responseData: 42,
      );
      expect(ex.message, contains('418'));
    });
  });
}
