import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_notifier.dart';

final translationNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<TranslationNotifier, TranslationState, int>(
  TranslationNotifier.new,
);

final translationStateProvider =
    Provider.autoDispose.family<TranslationState, int>((ref, projectId) {
  return ref.watch(translationNotifierProvider(projectId)).maybeWhen(
        data: (state) => state,
        orElse: () => TranslationState.initial(projectId),
      );
});
