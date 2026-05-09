import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/translation_provider.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier = ref.read(translationNotifierProvider(projectId).notifier);
    final items = LanguageCodes.getCodes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 560;
            final sourceDropdown = DropdownButtonFormField<String>(
              value: state.sourceLang,
              decoration: const InputDecoration(
                labelText: 'Source language',
              ),
              items: items
                  .map(
                    (code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(LanguageCodes.getLanguageName(code)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: state.isBusy
                  ? null
                  : (value) {
                      if (value != null) {
                        notifier.updateSourceLang(value);
                      }
                    },
            );

            final targetDropdown = DropdownButtonFormField<String>(
              value: state.targetLang,
              decoration: const InputDecoration(
                labelText: 'Target language',
              ),
              items: items
                  .map(
                    (code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(LanguageCodes.getLanguageName(code)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: state.isBusy
                  ? null
                  : (value) {
                      if (value != null) {
                        notifier.updateTargetLang(value);
                      }
                    },
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: sourceDropdown),
                  const SizedBox(width: 12),
                  Expanded(child: targetDropdown),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sourceDropdown,
                const SizedBox(height: 12),
                targetDropdown,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.translate_outlined,
              size: 18,
              color: AppTheme.tertiaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${LanguageCodes.getLanguageName(state.sourceLang)} -> ${LanguageCodes.getLanguageName(state.targetLang)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
