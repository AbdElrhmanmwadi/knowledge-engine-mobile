import 'package:flutter/material.dart';

class OutputCard extends StatelessWidget {
  const OutputCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.content,
    required this.accentColor,
    required this.card,
    required this.textSecondary,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final String content;
  final Color accentColor;
  final Color card;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isEmpty = content.isEmpty;
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty
              ? Colors.white.withOpacity(0.07)
              : accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                if (!isEmpty) ...[
                  const Spacer(),
                  Text(
                    '${content.length} chars',
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText(
              isEmpty ? 'No output yet…' : content,
              style: TextStyle(
                color: isEmpty
                    ? textSecondary.withOpacity(0.5)
                    : const Color(0xFFF0F2FF),
                fontSize: 14,
                height: 1.6,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
