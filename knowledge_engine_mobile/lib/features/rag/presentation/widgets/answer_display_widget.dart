import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knowledge_engine_mobile/features/rag/presentation/pages/ask_page.dart';

import '../providers/rag_provider.dart';

class AnswerDisplayWidget extends ConsumerWidget {
  const AnswerDisplayWidget({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(ragStateProvider(projectId));
    final response = state.answerResponse;

    if (response == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: RColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RColors.accent.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: RColors.accent, size: 15),
                const SizedBox(width: 8),
                const Text(
                  'AI ANSWER',
                  style: TextStyle(
                    color: RColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (response.retrievedChunks != null)
                  _MiniPill(
                    label: '${response.retrievedChunks} chunks',
                    color: RColors.teal,
                  ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),

          // ── Answer body ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: SelectableText(
              response.answer,
              style: const TextStyle(
                color: RColors.textPrimary,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Signal + actions ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Row(
              children: [
                _MiniPill(
                  label: 'Signal: ${response.signal}',
                  color: RColors.textSecondary,
                ),
                const Spacer(),
                // Copy
                _IconAction(
                  icon: Icons.copy_outlined,
                  label: 'Copy',
                  color: RColors.accent,
                  onTap: () => _copy(
                    context,
                    response.answer,
                    'Answer copied to clipboard.',
                  ),
                ),
                if (state.hasDebugData) ...[
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: state.isDebugVisible
                        ? Icons.visibility_off_outlined
                        : Icons.bug_report_outlined,
                    label: state.isDebugVisible ? 'Hide debug' : 'Debug',
                    color: RColors.amber,
                    onTap: ref
                        .read(ragNotifierProvider(projectId).notifier)
                        .toggleDebugVisibility,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(label)));
  }
}

// ── Mini pill ───────────────────────────────────────────────────────────────
class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Icon action button ───────────────────────────────────────────────────────
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}