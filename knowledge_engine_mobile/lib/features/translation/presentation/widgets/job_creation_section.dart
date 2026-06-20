import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/constants.dart';
import '../../../projects/presentation/providers/recent_projects_provider.dart';
import '../providers/translation_provider.dart';
import 'language_selector_widget.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/directional_icon.dart';
import '../../../../l10n/l10n.dart';

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

  Future<void> _pickFile(BuildContext context) async {
    final notifier =
        ref.read(translationNotifierProvider(widget.projectId).notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => _FilePickerSheet(
        projectId: widget.projectId,
        onPick: (fileName) {
          notifier.updateFileId(fileName);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
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
      label: context.l10n.createJob,
      icon: Icons.add_circle_outline_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.submitTranslationRequest(widget.projectId),
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),

          // ── Choose a file from the project ─────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isBusy ? null : () => _pickFile(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              icon: Icon(Icons.folder_open_rounded, size: 18.r),
              label: Text(context.l10n.chooseFile),
            ),
          ),
          SizedBox(height: 12.h),

          // ── File ID field (auto-filled by the picker; editable) ────
          TextField(
            controller: _fileIdController,
            enabled: !state.isBusy,
            onChanged: notifier.updateFileId,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: context.l10n.fileId,
              hintText: context.l10n.fileId,
              helperText: state.fileIdInput.trim().isEmpty
                  ? context.l10n.noFileSelectedYet
                  : context.l10n.fileId,
              errorText: state.fileIdError,
                prefixIcon: Icon(Icons.insert_drive_file_outlined,
                  size: 18.r, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Language selector ─────────────────────────────────────
          LanguageSelectorWidget(projectId: widget.projectId),

          // ── Error ─────────────────────────────────────────────────
          if (state.creationError != null) ...[
            SizedBox(height: 12.h),
            _AlertBanner(
              icon: Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              message: state.creationError!,
            ),
          ],
          SizedBox(height: 16.h),

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
                disabledBackgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              icon: state.isCreatingJob
                      ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Theme.of(context).colorScheme.onSecondary),
                    )
                  : Icon(Icons.playlist_add_check_circle_outlined,
                      size: 18.r),
                label:
                  Text(state.isCreatingJob ? context.l10n.creating : context.l10n.createJob),
            ),
          ),

          // ── Created job result ────────────────────────────────────
          if (createdJob != null) ...[
            SizedBox(height: 16.h),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.secondary, size: 15.r),
              SizedBox(width: 6.w),
              Text(
                context.l10n.jobCreatedHeader,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SelectableText(
            job.jobId as String,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _MiniPill(label: context.l10n.statusLabel, value: job.status as String),
              _MiniPill(label: context.l10n.assetLabel, value: job.assetId as String),
              _MiniPill(
                label: context.l10n.routeLabel,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Shared section wrapper ─────────────────────────────────────────────────
class TSection extends StatelessWidget {
  const TSection({super.key, 
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16.r),
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: iconColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
            height: 20.h,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── File picker bottom sheet ───────────────────────────────────────────────
class _FilePickerSheet extends ConsumerWidget {
  const _FilePickerSheet({required this.projectId, required this.onPick});

  final int projectId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(projectFilesProvider(projectId));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.l10n.selectFileToTranslate,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AlertBanner(
                        icon: Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        message: context.l10n.couldNotLoadFiles,
                      ),
                      SizedBox(height: 8.h),
                      TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(projectFilesProvider(projectId)),
                        icon: Icon(Icons.refresh_rounded, size: 18.r),
                        label: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (files) {
                  if (files.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noFilesInProject,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: files.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Material(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () => onPick(file.fileName),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file_outlined,
                                    size: 18.w,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    file.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                ),
                                DirectionalIcon(Icons.chevron_right_rounded,
                                    size: 18.w,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.4)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
