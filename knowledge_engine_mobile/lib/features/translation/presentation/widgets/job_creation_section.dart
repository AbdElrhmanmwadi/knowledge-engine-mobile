import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/constants.dart';
import '../providers/translation_provider.dart';
import 'language_selector_widget.dart';
import '../../../../core/theme/app_radius.dart';

class JobCreationSection extends ConsumerStatefulWidget {
  const JobCreationSection({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<JobCreationSection> createState() => _JobCreationSectionState();
}

class _JobCreationSectionState extends ConsumerState<JobCreationSection> {
  late final TextEditingController _fileIdController;

  @override
  void initState() {
    super.initState();
    _fileIdController = TextEditingController();
  }

  @override
  void dispose() {
    _fileIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationStateProvider(widget.projectId));
    final notifier =
        ref.read(translationNotifierProvider(widget.projectId).notifier);
    final createdJob = state.createdJobResponse;

    if (_fileIdController.text != state.fileIdInput) {
      _fileIdController.value = TextEditingValue(
        text: state.fileIdInput,
        selection: TextSelection.collapsed(offset: state.fileIdInput.length),
      );
    }

    return TSection(
      label: 'Create Job',
      icon: Icons.add_circle_outline_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit a translation request for a file in project ${widget.projectId}.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── File ID field ──────────────────────────────────────────
          TextField(
            controller: _fileIdController,
            enabled: !state.isBusy,
            onChanged: notifier.updateFileId,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'File ID',
              hintText: 'Latest uploaded file ID will appear here',
              helperText: state.fileIdInput.trim().isEmpty
                  ? 'Upload a file first — the ID will auto-fill.'
                  : 'Auto-filled from the latest upload. Edit if needed.',
              errorText: state.fileIdError,
                prefixIcon: Icon(Icons.insert_drive_file_outlined,
                  size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 16),

          // ── Language selector ─────────────────────────────────────
          LanguageSelectorWidget(projectId: widget.projectId),

          // ── Error ─────────────────────────────────────────────────
          if (state.creationError != null) ...[
            const SizedBox(height: 12),
            _AlertBanner(
              icon: Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              message: state.creationError!,
            ),
          ],
          const SizedBox(height: 16),

          // ── Submit button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (state.isBusy || !state.canCreate)
                  ? null
                  : notifier.createTranslationJob,
                style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                disabledBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
                ),
              icon: state.isCreatingJob
                      ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Theme.of(context).colorScheme.onSecondary),
                    )
                  : const Icon(Icons.playlist_add_check_circle_outlined,
                      size: 18),
              label:
                  Text(state.isCreatingJob ? 'Creating…' : 'Create Job'),
            ),
          ),

          // ── Created job result ────────────────────────────────────
          if (createdJob != null) ...[
            const SizedBox(height: 16),
            _CreatedJobCard(job: createdJob),
          ],
        ],
      ),
    );
  }
}

// ── Created job result card ─────────────────────────────────────────────────
class _CreatedJobCard extends StatelessWidget {
  const _CreatedJobCard({required this.job});
  final dynamic job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.secondary, size: 15),
              const SizedBox(width: 6),
              Text(
                'JOB CREATED',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            job.jobId as String,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniPill(label: 'Status', value: job.status as String),
              _MiniPill(label: 'Asset', value: job.assetId as String),
              _MiniPill(
                label: 'Route',
                value:
                    '${LanguageCodes.getLanguageName(job.sourceLang as String)} → ${LanguageCodes.getLanguageName(job.targetLang as String)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Shared section wrapper ─────────────────────────────────────────────────
class TSection extends StatelessWidget {
  const TSection({
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.07)),
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
          Divider(
            color: Theme.of(context).dividerColor.withOpacity(0.06),
            height: 20,
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Alert banner ───────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
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