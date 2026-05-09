import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rag_notifier.dart';

final ragNotifierProvider =
    AsyncNotifierProvider.autoDispose.family<RagNotifier, RagState, int>(
  RagNotifier.new,
);

final ragStateProvider = Provider.autoDispose.family<RagState, int>((
  ref,
  projectId,
) {
  return ref.watch(ragNotifierProvider(projectId)).maybeWhen(
        data: (state) => state,
        orElse: () => RagState.initial(projectId),
      );
});
