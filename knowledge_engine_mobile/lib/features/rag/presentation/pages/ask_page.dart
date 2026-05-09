import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/rag_provider.dart';
import '../widgets/answer_display_widget.dart';
import '../widgets/answer_section.dart';
import '../widgets/debug_section_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_section.dart';

/// Ask Page - Semantic search and RAG question answering
class AskPage extends ConsumerWidget {
  final int projectId;

  const AskPage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI'),
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
                        AppTheme.primaryColor,
                        AppTheme.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search and ask across your knowledge',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project $projectId can search indexed chunks or generate a grounded RAG answer from the same knowledge base.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SearchSection(projectId: projectId),
                const SizedBox(height: 12),
                SearchResultsWidget(projectId: projectId),
                const SizedBox(height: 12),
                AnswerSection(projectId: projectId),
                const SizedBox(height: 12),
                AnswerDisplayWidget(projectId: projectId),
                const SizedBox(height: 12),
                DebugSectionWidget(projectId: projectId),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
