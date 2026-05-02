import 'dart:async';

import '../../../../core/models/translation_job_create_response.dart';
import '../../../../core/models/translation_job_status_response.dart';
import '../../../../core/network/api_service.dart';

/// Repository wrapper for translation job operations.
class TranslationRepository {
  TranslationRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  String? _trackedJobId;
  TranslationJobStatusResponse? _lastJobStatus;

  String? get trackedJobId => _trackedJobId;
  TranslationJobStatusResponse? get lastJobStatus => _lastJobStatus;

  Future<TranslationJobCreateResponse> createJob({
    required int projectId,
    required String fileId,
    required String sourceLang,
    required String targetLang,
  }) async {
    final response = await _apiService.createTranslationJob(
      projectId: projectId,
      fileId: fileId,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    _trackedJobId = response.jobId;
    return response;
  }

  Future<TranslationJobStatusResponse> getJobStatus({
    required String jobId,
  }) async {
    final response = await _apiService.getTranslationStatus(jobId: jobId);
    _trackedJobId = jobId;
    _lastJobStatus = response;
    return response;
  }

  Stream<TranslationJobStatusResponse> pollJobStatus({
    required String jobId,
    Duration interval = const Duration(seconds: 5),
    bool stopOnTerminalStatus = true,
  }) async* {
    while (true) {
      final response = await getJobStatus(jobId: jobId);
      yield response;

      if (stopOnTerminalStatus && _isTerminalStatus(response.job.status)) {
        break;
      }

      await Future<void>.delayed(interval);
    }
  }

  void clearTrackedJob() {
    _trackedJobId = null;
    _lastJobStatus = null;
  }

  bool _isTerminalStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'completed' || normalized == 'failed';
  }
}
