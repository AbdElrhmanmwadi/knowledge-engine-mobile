import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/translation_provider.dart';
import '../widgets/job_creation_section.dart';
import '../widgets/job_status_section.dart';

/// Translate Page - File translation job management
class TranslatePage extends ConsumerWidget {
  final int projectId;

  const TranslatePage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationStateProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Translation'),
        centerTitle: false,
      ),
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        AppTheme.tertiaryColor,
                        AppTheme.warningColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translate project files with tracked job status',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project $projectId can create translation jobs, poll the backend for progress, and capture result file IDs once jobs complete.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                JobCreationSection(projectId: projectId),
                const SizedBox(height: 12),
                JobStatusSection(projectId: projectId),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
