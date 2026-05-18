import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/rag_provider.dart';
import 'package:knowledge_engine_mobile/features/rag/presentation/pages/ask_page.dart'; // RColors
class AnswerSection extends ConsumerWidget {
  const AnswerSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(ragStateProvider(projectId));
    final notifier = ref.read(ragNotifierProvider(projectId).notifier);

    return RSection(
      label: 'Ask AI',
      icon: Icons.auto_awesome_rounded,
      iconColor: RColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask a question about the indexed knowledge in project $projectId.',
            style: const TextStyle(color: RColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── Question field ────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(color: RColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Your question',
              hintText: 'Ask anything about your uploaded knowledge…',
              alignLabelWithHint: true,
              filled: true,
              fillColor: RColors.card,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 52),
                child: Icon(Icons.help_outline_rounded,
                    size: 18, color: RColors.textSecondary),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: RColors.accent, width: 1.5),
              ),
            ),
            onChanged: notifier.updateQuestion,
          ),
          const SizedBox(height: 12),

          // ── Limit field ───────────────────────────────────────────
          TextField(
            enabled: !state.isBusy,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: RColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Retrieved chunks limit',
              hintText: state.answerLimit.toString(),
              helperText:
                  'Range: ${ValidationConstants.minRagLimit}–${ValidationConstants.maxRagLimit}',
              helperStyle:
                  const TextStyle(color: RColors.textSecondary, fontSize: 11),
              errorText: state.answerLimitError,
              filled: true,
              fillColor: RColors.card,
              prefixIcon: const Icon(Icons.layers_outlined,
                  size: 18, color: RColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: RColors.accent, width: 1.5),
              ),
            ),
            onChanged: notifier.updateAnswerLimit,
          ),

          // ── Error ─────────────────────────────────────────────────
          if (state.answerErrorMessage != null) ...[
            const SizedBox(height: 12),
            RAlertBanner(
              icon: Icons.error_outline_rounded,
              color: RColors.error,
              message: state.answerErrorMessage!,
            ),
          ],
          const SizedBox(height: 16),

          // ── Submit ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  (state.isBusy || !state.canAsk) ? null : notifier.askQuestion,
              style: FilledButton.styleFrom(
                backgroundColor: RColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: RColors.accent.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              icon: state.isAnswering
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(state.isAnswering ? 'Thinking…' : 'Ask'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared section wrapper ─────────────────────────────────────────────────
class RSection extends StatelessWidget {
  const RSection({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: iconColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),
          child,
        ],
      ),
    );
  }
}

// ─── Alert banner ────────────────────────────────────────────────────────────
class RAlertBanner extends StatelessWidget {
  const RAlertBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}