import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_notifier.dart';

export 'voice_notifier.dart' show VoiceNotifier, VoiceState;

final voiceNotifierProvider =
    AsyncNotifierProvider.autoDispose.family<VoiceNotifier, VoiceState, int>(
  VoiceNotifier.new,
);

final voiceStateProvider = Provider.autoDispose.family<VoiceState, int>((
  ref,
  projectId,
) {
  return ref.watch(voiceNotifierProvider(projectId)).maybeWhen(
        data: (state) => state,
        orElse: () => VoiceState.initial(projectId),
      );
});
