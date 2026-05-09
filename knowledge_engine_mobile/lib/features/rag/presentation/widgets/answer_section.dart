import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/rag_provider.dart';

class AnswerSection extends ConsumerWidget {
  const AnswerSection({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ragStateProvider(projectId));
    final notifier = ref.read(ragNotifierProvider(projectId).notifier);
    final featureColor = AppTheme.getFeatureColor('ask');

    return AppCard(
      title: 'Ask AI',
      children: [
        Text(
          'Ask a question about the indexed knowledge in project $projectId.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: !state.isBusy,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Question',
            hintText: 'Ask a question about your uploaded knowledge',
            alignLabelWithHint: true,
          ),
          onChanged: notifier.updateQuestion,
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: !state.isBusy,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: 'Retrieved chunks limit',
            hintText: state.answerLimit.toString(),
            helperText:
                'Range: ${ValidationConstants.minRagLimit}-${ValidationConstants.maxRagLimit}',
            errorText: state.answerLimitError,
          ),
          onChanged: notifier.updateAnswerLimit,
        ),
        if (state.answerErrorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.answerErrorMessage!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Ask',
            icon: Icons.auto_awesome,
            onPressed: notifier.askQuestion,
            isLoading: state.isAnswering,
            isEnabled: state.canAsk,
            style: ElevatedButton.styleFrom(
              backgroundColor: featureColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
