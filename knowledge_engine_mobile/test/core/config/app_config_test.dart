import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/core/config/app_config.dart';

void main() {
  group('AppConfig.getBaseUrl', () {
    test('an explicit override URL wins over everything', () {
      expect(
        AppConfig.getBaseUrl(overrideUrl: 'https://custom.example.com'),
        'https://custom.example.com',
      );
    });

    test('an empty override is ignored (falls through to defaults)', () {
      final url = AppConfig.getBaseUrl(overrideUrl: '');
      expect(url, isNotEmpty);
    });

    test('the production URL is HTTPS', () {
      expect(AppConfig.prodBaseUrl, startsWith('https://'));
    });

    test('resolves to a non-empty base URL with no arguments', () {
      expect(AppConfig.getBaseUrl(), isNotEmpty);
    });
  });
}
