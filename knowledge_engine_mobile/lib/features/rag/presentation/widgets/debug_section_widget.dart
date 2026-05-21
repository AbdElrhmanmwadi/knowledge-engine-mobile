import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';

class DebugSectionWidget extends ConsumerWidget {
  const DebugSectionWidget({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));
    final response = state.answerResponse;

    if (response == null || !state.isDebugVisible || !state.hasDebugData) {
      return const SizedBox.shrink();
    }

    final chatHistory = response.chatHistory ?? const <Map<String, dynamic>>[];

    return AppCard(
      title: 'Debug Info',
      children: [
        if (response.fullPrompt != null && response.fullPrompt!.trim().isNotEmpty) ...[
          _DebugBlock(
            title: 'Full Prompt',
            content: response.fullPrompt!,
          ),
          SizedBox(height: 12.h),
        ],
        if (chatHistory.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chat History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _copyText(
                  context,
                  chatHistory
                      .map(
                        (item) =>
                            '${item['role'] ?? 'unknown'}: ${item['content'] ?? ''}',
                      )
                      .join('\n\n'),
                  'Chat history copied to clipboard.',
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          for (var index = 0; index < chatHistory.length; index++) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${chatHistory[index]['role'] ?? 'unknown'}'.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  SelectableText(
                    '${chatHistory[index]['content'] ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (index < chatHistory.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ],
    );
  }

  Future<void> _copyText(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
  }
}

class _DebugBlock extends StatelessWidget {
  const _DebugBlock({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: content));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prompt copied to clipboard.')),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: AppTheme.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
