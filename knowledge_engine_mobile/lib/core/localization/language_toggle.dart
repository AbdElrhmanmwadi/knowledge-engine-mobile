import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import 'locale_controller.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final notifier = ref.read(localeProvider.notifier);
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      tooltip: l10n.language,
      icon: const Icon(Icons.language_rounded),
      initialValue: locale?.languageCode ?? 'system',
      onSelected: (value) {
        notifier.setLocale(value == 'system' ? null : Locale(value));
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'system', child: Text(l10n.systemLanguage)),
        PopupMenuItem(value: 'en', child: Text(l10n.english)),
        PopupMenuItem(value: 'ar', child: Text(l10n.arabic)),
      ],
    );
  }
}
