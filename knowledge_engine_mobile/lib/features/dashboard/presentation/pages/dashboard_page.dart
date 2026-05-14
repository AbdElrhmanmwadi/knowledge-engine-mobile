import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

/// Dashboard Page - Project overview and navigation hub
class DashboardPage extends StatelessWidget {
  final int projectId;

  const DashboardPage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppTheme.primaryColor,
                      AppTheme.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your project is ready',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Project #$projectId',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pick what you want to do next. You can always come back here.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Next steps',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _DashboardActionCard(
                title: 'Add documents',
                description: 'Upload files and prepare them for searching.',
                icon: Icons.folder_open_outlined,
                color: AppTheme.secondaryColor,
                onTap: () => context.push('/files', extra: projectId),
              ),
              _DashboardActionCard(
                title: 'Ask questions',
                description: 'Search and ask the AI using your project documents.',
                icon: Icons.auto_awesome_outlined,
                color: AppTheme.primaryColor,
                onTap: () => context.push('/ask', extra: projectId),
              ),
              _DashboardActionCard(
                title: 'Voice',
                description: 'Transcribe speech, hear text aloud, or ask by voice.',
                icon: Icons.mic_none_outlined,
                color: AppTheme.voiceColor,
                onTap: () => context.push('/voice', extra: projectId),
              ),
              _DashboardActionCard(
                title: 'Translate a file',
                description: 'Request a translation and download the result.',
                icon: Icons.translate_outlined,
                color: AppTheme.tertiaryColor,
                onTap: () => context.push('/translate', extra: projectId),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/projects'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Switch project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
