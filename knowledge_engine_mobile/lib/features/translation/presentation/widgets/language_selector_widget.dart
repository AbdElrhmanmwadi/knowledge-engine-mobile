import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/translation_provider.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier =
        ref.read(translationNotifierProvider(projectId).notifier);
    final items = LanguageCodes.getCodes();

    final sourceDropdown = _buildDropdown(
      context: context,
      label: 'Source language',
      value: state.sourceLang,
      items: items,
      disabled: state.isBusy,
      onChanged: (v) {
        if (v != null) notifier.updateSourceLang(v);
      },
    );

    final targetDropdown = _buildDropdown(
      context: context,
      label: 'Target language',
      value: state.targetLang,
      items: items,
      disabled: state.isBusy,
      onChanged: (v) {
        if (v != null) notifier.updateTargetLang(v);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section micro-label ──────────────────────────────────────
        Row(
          children: [
            Icon(Icons.translate_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'LANGUAGES',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Dropdowns ────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 480;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: sourceDropdown),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      size: 18),
                  ),
                  Expanded(child: targetDropdown),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sourceDropdown,
                const SizedBox(height: 10),
                Center(
                  child: Icon(Icons.arrow_downward_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      size: 18),
                ),
                const SizedBox(height: 10),
                targetDropdown,
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // ── Route preview ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route_rounded,
                  size: 13, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 7),
              Text(
                '${LanguageCodes.getLanguageName(state.sourceLang)} → ${LanguageCodes.getLanguageName(state.targetLang)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required bool disabled,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).textTheme.bodyMedium?.color, size: 18),
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
        ),
      ),
      items: items
          .map(
            (code) => DropdownMenuItem<String>(
              value: code,
              child: Text(LanguageCodes.getLanguageName(code)),
            ),
          )
          .toList(growable: false),
      onChanged: disabled ? null : onChanged,
    );
  }
}