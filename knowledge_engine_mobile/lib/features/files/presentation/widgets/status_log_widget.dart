import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/files_provider.dart';

class StatusLogWidget extends ConsumerStatefulWidget {
  const StatusLogWidget({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<StatusLogWidget> createState() => _StatusLogWidgetState();
}

class _StatusLogWidgetState extends ConsumerState<StatusLogWidget> {
  final ScrollController _scrollController = ScrollController();
  int _lastLogCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(filesStatusLogProvider(widget.projectId));
    final notifier = ref.read(filesNotifierProvider(widget.projectId).notifier);

    if (logs.length != _lastLogCount) {
      _lastLogCount = logs.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }

    return AppCard(
      title: 'Status Log',
      children: [
        Row(
          children: [
            Text(
              '${logs.length} entries',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: logs.isEmpty
                  ? null
                  : () async {
                      final text = logs.map((entry) {
                        final time =
                            DateFormat('HH:mm:ss').format(entry.timestamp);
                        return '[$time] ${entry.label}: ${entry.message}';
                      }).join('\n');

                      await Clipboard.setData(ClipboardData(text: text));
                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status log copied.')),
                      );
                    },
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy'),
            ),
            TextButton.icon(
              onPressed: logs.isEmpty ? null : notifier.clearStatus,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: logs.isEmpty
              ? Center(
                  child: Text(
                    'No activity yet. Actions will appear here with timestamps.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: logs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = logs[index];
                    final time =
                        DateFormat('HH:mm:ss').format(entry.timestamp);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge(
                                status: entry.status,
                                label: entry.label,
                                fontSize: 12,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                time,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            entry.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
