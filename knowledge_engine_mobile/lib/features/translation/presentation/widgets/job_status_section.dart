import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knowledge_engine_mobile/features/translation/presentation/widgets/job_creation_section.dart';
import 'package:knowledge_engine_mobile/features/voice/presentation/widgets/alert_banner.dart';

import '../providers/translation_provider.dart';
// for _TSection, _AlertBanner
import 'translation_status_card.dart';

class JobStatusSection extends ConsumerWidget {
  const JobStatusSection({super.key, required this.projectId});
  final int projectId;

  static const List<int> _refreshOptions = <int>[1, 3, 5, 10, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));
    final notifier =
        ref.read(translationNotifierProvider(projectId).notifier);
    final latestJobId = state.createdJobResponse?.jobId;

    return TSection(
      label: 'Translation Status',
      icon: Icons.track_changes_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Well track the latest translation request for you.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
          ),
          const SizedBox(height: 14),

          // ── Latest job badge ────────────────────────────────────
          if (latestJobId != null && latestJobId.trim().isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.22)),
              ),
              child: Row(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      latestJobId,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      size: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Create a translation job first to see its status here.',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // ── Advanced / manual job ID ────────────────────────────
          _AdvancedExpansion(state: state, notifier: notifier),

          if (state.statusError != null) ...[
            const SizedBox(height: 10),
            AlertBanner(
              icon: Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              message: state.statusError!,
            ),
          ],
          const SizedBox(height: 16),

          // ── Refresh button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canCheck)
                  ? null
                  : notifier.checkJobStatus,
                style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: const Color(0xFF0D0F14),
                disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
                ),
              icon: state.isCheckingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF0D0F14)),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                  state.isCheckingStatus ? 'Checking…' : 'Refresh status'),
            ),
          ),
          const SizedBox(height: 14),

          // ── Auto-refresh controls ───────────────────────────────
          _AutoRefreshRow(
            state: state,
            notifier: notifier,
            refreshOptions: _refreshOptions,
          ),

          // ── Status card ─────────────────────────────────────────
          if (state.hasVisibleStatusCard) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (state.canCheck)
                  _TinyButton(
                    icon: Icons.sync_rounded,
                    label: 'Refresh now',
                    onTap: notifier.checkJobStatus,
                  ),
                const Spacer(),
                _TinyButton(
                  icon: Icons.clear_all_outlined,
                  label: 'Clear',
                  onTap: notifier.clearJob,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TranslationStatusCard(projectId: projectId),
          ],
        ],
      ),
    );
  }
}

// ── Subwidgets ──────────────────────────────────────────────────────────────

class _AdvancedExpansion extends StatelessWidget {
  const _AdvancedExpansion({required this.state, required this.notifier});
  final dynamic state;
  final dynamic notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding:
            const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.tune_rounded,
            color: Theme.of(context).textTheme.bodyMedium?.color, size: 18),
        title: Text(
          'Advanced',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Look up a different request by ID',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11),
        ),
        children: [
          TextField(
            enabled: !(state.isBusy as bool),
            onChanged: notifier.updateJobStatusId,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Request ID',
              hintText: 'Optional — leave empty for latest',
              errorText: state.jobStatusIdError as String?,
              prefixIcon: Icon(Icons.tag_rounded,
                  size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoRefreshRow extends StatelessWidget {
  const _AutoRefreshRow({
    required this.state,
    required this.notifier,
    required this.refreshOptions,
  });
  final dynamic state;
  final dynamic notifier;
  final List<int> refreshOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.autorenew_rounded,
                  size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep updating automatically',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Refresh every ${state.refreshIntervalSeconds}s until complete',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.autoRefreshEnabled as bool,
                onChanged: (v) => notifier.toggleAutoRefresh(v),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: state.refreshIntervalSeconds as int,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Refresh interval',
              prefixIcon: Icon(Icons.timer_outlined,
                  size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
              ),
            ),
            items: refreshOptions
                .map(
                  (s) => DropdownMenuItem<int>(
                    value: s,
                    child: Text('$s seconds'),
                  ),
                )
                .toList(growable: false),
            onChanged: (state.isBusy as bool)
                ? null
                : (v) {
                    if (v != null) notifier.updateRefreshInterval(v);
                  },
          ),
        ],
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({
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
    final btnColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: btnColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: btnColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: btnColor, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: btnColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}