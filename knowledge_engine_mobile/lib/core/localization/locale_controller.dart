import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  static const _storageKey = 'locale';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_storageKey);
    state = code == null || code == 'system' ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_storageKey, locale?.languageCode ?? 'system');
  }
}
