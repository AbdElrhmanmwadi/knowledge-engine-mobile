import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/files_provider.dart';
import '../pages/files_page.dart';    // FColors

class StatusLogWidget extends ConsumerStatefulWidget {
  const StatusLogWidget({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<StatusLogWidget> createState() => _StatusLogWidgetState();
}

class _StatusLogWidgetState extends ConsumerState<StatusLogWidget> {
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs    = ref.watch(filesStatusLogProvider(widget.projectId));
    final notifier =
        ref.read(filesNotifierProvider(widget.projectId).notifier);

    if (logs.length != _lastCount) {
      _lastCount = logs.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: FColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded,
                    color: FColors.textSecondary, size: 15),
                const SizedBox(width: 8),
                const Text(
                  'STATUS LOG',
                  style: TextStyle(
                    color: FColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
                if (logs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: FColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${logs.length}',
                      style: const TextStyle(
                        color: FColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                // Copy
                if (logs.isNotEmpty)
                  _LogAction(
                    icon: Icons.copy_outlined,
                    label: 'Copy',
                    onTap: () async {
                      final text = logs.map((e) {
                        final t = DateFormat('HH:mm:ss')
                            .format(e.timestamp);
                        return '[$t] ${e.label}: ${e.message}';
                      }).join('\n');
                      await Clipboard.setData(
                          ClipboardData(text: text));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Status log copied.')),
                      );
                    },
                  ),
                if (logs.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _LogAction(
                    icon: Icons.delete_sweep_outlined,
                    label: 'Clear',
                    color: FColors.error,
                    onTap: notifier.clearStatus,
                  ),
                ],
                const SizedBox(width: 10),
              ],
            ),
          ),
          Divider(
              color: Colors.white.withOpacity(0.06), height: 18),

          // ── Log list ──────────────────────────────────────────────
          SizedBox(
            height: 260,
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded,
                            color: FColors.textSecondary
                                .withOpacity(0.3),
                            size: 32),
                        const SizedBox(height: 10),
                        Text(
                          'No activity yet.',
                          style: TextStyle(
                            color: FColors.textSecondary
                                .withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Actions will appear here with timestamps.',
                          style: TextStyle(
                            color: FColors.textSecondary
                                .withOpacity(0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final entry = logs[i];
                      return _LogEntry(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Log entry ────────────────────────────────────────────────────────────────
class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.entry});
  final dynamic entry;

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return FColors.accent;
      case 'error':
      case 'failed':
        return FColors.error;
      case 'warning':
        return FColors.warning;
      default:
        return FColors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time  = DateFormat('HH:mm:ss').format(entry.timestamp as DateTime);
    final color = _statusColor(entry.status as String);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (entry.label as String).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  color: FColors.textSecondary,
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.message as String,
            style: const TextStyle(
              color: FColors.textPrimary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Log action button ────────────────────────────────────────────────────────
class _LogAction extends StatelessWidget {
  const _LogAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = FColors.textSecondary,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}