import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../providers/files_provider.dart';
import '../pages/files_page.dart';    // FColors
import 'upload_section.dart'; // FSection

class ProcessSection extends ConsumerWidget {
  const ProcessSection({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(filesStateProvider(projectId));
    final notifier = ref.read(filesNotifierProvider(projectId).notifier);
    final locked  = state.fileId == null;

    return FSection(
      stepNumber: 2,
      label: 'Prepare Document',
      icon: Icons.auto_awesome_motion_outlined,
      isComplete: state.processResponse != null,
      isLocked: locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locked
                ? 'Upload a file first to unlock this step.'
                : 'Prepares your document for search and question answering.',
            style: const TextStyle(
                color: FColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── Replace previous checkbox ───────────────────────────
          DarkCheckTile(
            value: state.processDoReset,
            disabled: state.isBusy,
            title: 'Replace previous preparation',
            subtitle:
                'Use this if you re-uploaded or changed the file.',
            onChanged: (v) =>
                notifier.toggleProcessDoReset(v ?? false),
          ),
          const SizedBox(height: 12),

          // ── Advanced settings ───────────────────────────────────
          _AdvancedPanel(
            isBusy: state.isBusy,
            isExpanded: state.showAdvancedOptions,
            onExpand: notifier.toggleAdvancedOptions,
            children: [
              _DarkTextField(
                label: 'Chunk size',
                hint: state.chunkSize.toString(),
                helper:
                    'Range: ${ValidationConstants.minChunkSize}–${ValidationConstants.maxChunkSize}',
                errorText: state.chunkSizeError,
                disabled: state.isBusy,
                onChanged: notifier.updateChunkSize,
              ),
              const SizedBox(height: 12),
              _DarkTextField(
                label: 'Overlap size',
                hint: state.overlapSize.toString(),
                helper:
                    'Range: ${ValidationConstants.minOverlapSize}–${ValidationConstants.maxOverlapSize}',
                errorText: state.overlapSizeError,
                disabled: state.isBusy,
                onChanged: notifier.updateOverlapSize,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 13,
                      color: FColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Only change these if you know what you\'re optimising for.',
                      style: TextStyle(
                        color: FColors.textSecondary.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Prepare button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canProcess || locked)
                  ? null
                  : notifier.processFile,
              style: FilledButton.styleFrom(
                backgroundColor: FColors.accent,
                foregroundColor: FColors.bg,
                disabledBackgroundColor:
                    FColors.accent.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              icon: state.isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: FColors.bg),
                    )
                  : const Icon(
                      Icons.auto_awesome_motion_outlined, size: 18),
              label: Text(state.isProcessing
                  ? 'Preparing…'
                  : 'Prepare document'),
            ),
          ),

          // ── Process result ──────────────────────────────────────
          if (state.processResponse != null) ...[
            const SizedBox(height: 16),
            _ProcessResult(response: state.processResponse!),
          ],
        ],
      ),
    );
  }
}

// ── Process result card ──────────────────────────────────────────────────────
class _ProcessResult extends StatelessWidget {
  const _ProcessResult({required this.response});
  final dynamic response;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FColors.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: FColors.accent, size: 14),
              const SizedBox(width: 6),
              const Text(
                'PROCESSING COMPLETE',
                style: TextStyle(
                  color: FColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: 'Chunks inserted',
                value: response.insertedChunks.toString(),
              ),
              _MetricChip(
                label: 'Files processed',
                value: response.processedFiles.toString(),
              ),
              if (response.fileId != null)
                _MetricChip(
                  label: 'File ID',
                  value: response.fileId as String,
                  mono: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: FColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 3),
          SelectableText(
            value,
            style: TextStyle(
              color: FColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'Courier' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Advanced collapsible panel ───────────────────────────────────────────────
class _AdvancedPanel extends StatelessWidget {
  const _AdvancedPanel({
    required this.isBusy,
    required this.isExpanded,
    required this.onExpand,
    required this.children,
  });
  final bool isBusy;
  final bool isExpanded;
  final ValueChanged<bool>? onExpand;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.tune_rounded,
            color: FColors.textSecondary, size: 17),
        title: const Text(
          'Advanced',
          style: TextStyle(
              color: FColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          'Default settings work for most files',
          style: TextStyle(color: FColors.textSecondary, fontSize: 11),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: isBusy ? null : onExpand,
        children: children,
      ),
    );
  }
}

// ── Dark-styled checkbox tile ────────────────────────────────────────────────
class DarkCheckTile extends StatelessWidget {
  const DarkCheckTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.disabled = false,
  });
  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool?> onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? FColors.accent.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? FColors.accent.withOpacity(0.25)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: disabled ? null : onChanged,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: FColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: FColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dark text field ──────────────────────────────────────────────────────────
class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.label,
    required this.hint,
    required this.helper,
    required this.onChanged,
    this.errorText,
    this.disabled = false,
  });
  final String label;
  final String hint;
  final String helper;
  final String? errorText;
  final bool disabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: !disabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: FColors.textPrimary, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: errorText,
      ),
    );
  }
}