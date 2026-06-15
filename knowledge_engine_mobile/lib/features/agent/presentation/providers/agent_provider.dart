import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_notifier.dart';

final agentNotifierProvider =
    AsyncNotifierProvider.autoDispose.family<AgentNotifier, AgentState, int>(
  AgentNotifier.new,
);

final agentStateProvider = Provider.autoDispose.family<AgentState, int>((
  ref,
  projectId,
) {
  return ref.watch(agentNotifierProvider(projectId)).maybeWhen(
        data: (state) => state,
        orElse: () => AgentState.initial(projectId),
      );
});
