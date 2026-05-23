import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/l10n.dart';

import '../providers/files_provider.dart';
 

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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 8.w, 0.h),
            child: Row(
              children: [
                Icon(Icons.terminal_rounded,
                    color: Theme.of(context).textTheme.bodyMedium?.color, size: 15.r),
                SizedBox(width: 8.w),
                Text(
                  context.l10n.statusLog,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 6.w),
                if (logs.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${logs.length}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                // Copy
                if (logs.isNotEmpty)
                  _LogAction(
                    icon: Icons.copy_outlined,
                    label: context.l10n.copy,
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
                        SnackBar(
                            content: Text(context.l10n.statusLogCopied)),
                      );
                    },
                  ),
                if (logs.isNotEmpty) ...[ 
                  SizedBox(width: 6.w),
                    _LogAction(
                    icon: Icons.delete_sweep_outlined,
                    label: context.l10n.clear,
                    color: Theme.of(context).colorScheme.error,
                    onTap: notifier.clearStatus,
                  ),
                ],
                SizedBox(width: 10.w),
              ],
            ),
          ),
            Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.06), height: 18.h),

          // ── Log list ──────────────────────────────────────────────
          SizedBox(
            height: 260.h,
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                            size: 32.r),
                        SizedBox(height: 10.h),
                        Text(
                          context.l10n.noActivityYet,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          context.l10n.actionsWillAppear,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: 8.h),
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

  static Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Theme.of(context).colorScheme.primary;
      case 'error':
      case 'failed':
        return Theme.of(context).colorScheme.error;
      case 'warning':
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time  = DateFormat('HH:mm:ss').format(entry.timestamp as DateTime);
    final color = _statusColor(context, entry.status as String);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  (entry.label as String).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 10.sp,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            entry.message as String,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 12.sp,
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
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 13.r),
            SizedBox(width: 4.w),
            Text(label,
                style: TextStyle(
                    color: c,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
