import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'files_notifier.dart';

final filesNotifierProvider =
    AsyncNotifierProvider.autoDispose.family<FilesNotifier, FilesState, int>(
  FilesNotifier.new,
);

final filesStateProvider = Provider.autoDispose.family<FilesState, int>((
  ref,
  projectId,
) {
  return ref.watch(filesNotifierProvider(projectId)).maybeWhen(
        data: (state) => state,
        orElse: () => FilesState.initial(projectId),
      );
});

final filesErrorMessageProvider =
    Provider.autoDispose.family<String?, int>((ref, projectId) {
  return ref.watch(filesStateProvider(projectId)).errorMessage;
});

final filesStatusLogProvider =
    Provider.autoDispose.family<List<StatusLogEntry>, int>((ref, projectId) {
  return ref.watch(filesStateProvider(projectId)).statusLog;
});
