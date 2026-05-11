import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/translation_job_create_response.dart';
import '../../../../core/models/translation_job_status_response.dart';
import '../../data/repositories/translation_repository.dart';

class TranslationState {
  const TranslationState({
    required this.currentProjectId,
    this.fileIdInput = '',
    this.fileIdError,
    this.sourceLang = LanguageCodes.defaultSourceLanguage,
    this.targetLang = LanguageCodes.defaultTargetLanguage,
    this.isCreatingJob = false,
    this.createdJobResponse,
    this.creationError,
    this.jobStatusIdInput = '',
    this.jobStatusIdError,
    this.isCheckingStatus = false,
    this.jobStatusResponse,
    this.statusError,
    this.autoRefreshEnabled = false,
    this.refreshIntervalSeconds = AppConfig.translationPollInterval,
    this.lastRefreshTime,
    this.isDownloading = false,
    this.downloadError,
    this.lastDownloadedPath,
  });

  factory TranslationState.initial(int projectId) {
    return TranslationState(currentProjectId: projectId);
  }

  final int currentProjectId;
  final String fileIdInput;
  final String? fileIdError;
  final String sourceLang;
  final String targetLang;
  final bool isCreatingJob;
  final TranslationJobCreateResponse? createdJobResponse;
  final String? creationError;
  final String jobStatusIdInput;
  final String? jobStatusIdError;
  final bool isCheckingStatus;
  final TranslationJobStatusResponse? jobStatusResponse;
  final String? statusError;
  final bool autoRefreshEnabled;
  final int refreshIntervalSeconds;
  final DateTime? lastRefreshTime;
  final bool isDownloading;
  final String? downloadError;
  final String? lastDownloadedPath;

  bool get isBusy => isCreatingJob || isCheckingStatus;

  bool get canCreate =>
      fileIdInput.trim().isNotEmpty && !isBusy && fileIdError == null;

  String? get resolvedJobId {
    final manual = jobStatusIdInput.trim();
    if (manual.isNotEmpty) {
      return manual;
    }

    final created = createdJobResponse?.jobId.trim();
    if (created != null && created.isNotEmpty) {
      return created;
    }

    return null;
  }

  bool get canCheck =>
      resolvedJobId != null && !isBusy && jobStatusIdError == null;

  bool get hasVisibleStatusCard =>
      createdJobResponse != null || jobStatusResponse != null;

  String? get activeLoadingMessage {
    if (isCreatingJob) {
      return 'Creating translation job...';
    }
    if (isCheckingStatus) {
      return 'Refreshing translation job status...';
    }
    return null;
  }

  static const Object _unset = Object();

  TranslationState copyWith({
    String? fileIdInput,
    Object? fileIdError = _unset,
    String? sourceLang,
    String? targetLang,
    bool? isCreatingJob,
    Object? createdJobResponse = _unset,
    Object? creationError = _unset,
    String? jobStatusIdInput,
    Object? jobStatusIdError = _unset,
    bool? isCheckingStatus,
    Object? jobStatusResponse = _unset,
    Object? statusError = _unset,
    bool? autoRefreshEnabled,
    int? refreshIntervalSeconds,
    Object? lastRefreshTime = _unset,
    bool? isDownloading,
    Object? downloadError = _unset,
    Object? lastDownloadedPath = _unset,
  }) {
    return TranslationState(
      currentProjectId: currentProjectId,
      fileIdInput: fileIdInput ?? this.fileIdInput,
      fileIdError:
          identical(fileIdError, _unset) ? this.fileIdError : fileIdError as String?,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      isCreatingJob: isCreatingJob ?? this.isCreatingJob,
      createdJobResponse: identical(createdJobResponse, _unset)
          ? this.createdJobResponse
          : createdJobResponse as TranslationJobCreateResponse?,
      creationError:
          identical(creationError, _unset) ? this.creationError : creationError as String?,
      jobStatusIdInput: jobStatusIdInput ?? this.jobStatusIdInput,
      jobStatusIdError: identical(jobStatusIdError, _unset)
          ? this.jobStatusIdError
          : jobStatusIdError as String?,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
      jobStatusResponse: identical(jobStatusResponse, _unset)
          ? this.jobStatusResponse
          : jobStatusResponse as TranslationJobStatusResponse?,
      statusError:
          identical(statusError, _unset) ? this.statusError : statusError as String?,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      lastRefreshTime: identical(lastRefreshTime, _unset)
          ? this.lastRefreshTime
          : lastRefreshTime as DateTime?,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadError: identical(downloadError, _unset)
          ? this.downloadError
          : downloadError as String?,
      lastDownloadedPath: identical(lastDownloadedPath, _unset)
          ? this.lastDownloadedPath
          : lastDownloadedPath as String?,
    );
  }
}

class TranslationNotifier extends AsyncNotifier<TranslationState> {
  TranslationNotifier(this._projectId);

  final int _projectId;
  late TranslationRepository _repository;
  SharedPreferences? _prefs;
  StreamSubscription<TranslationJobStatusResponse>? _pollingSubscription;
  bool _isDisposed = false;

  @override
  TranslationState build() {
    _repository = TranslationRepository();
    ref.onDispose(() {
      _isDisposed = true;
      _pollingSubscription?.cancel();
    });
    _restoreStoredPreferences();
    return TranslationState.initial(_projectId);
  }

  TranslationState get _currentState => state.maybeWhen(
        data: (value) => value,
        orElse: () => TranslationState.initial(_projectId),
      );

  void _updateState(TranslationState nextState) {
    if (_isDisposed) {
      return;
    }
    state = AsyncValue.data(nextState);
  }

  Future<void> _restoreStoredPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isDisposed) {
      return;
    }

    _prefs = prefs;
    final source = prefs.getString(StorageKeys.lastSourceLanguage);
    final target = prefs.getString(StorageKeys.lastTargetLanguage);
    final latestFileId = prefs.getString(
      StorageKeys.latestFileIdForProject(_projectId),
    );

    _updateState(_currentState.copyWith(
      fileIdInput:
          latestFileId != null && latestFileId.trim().isNotEmpty
              ? latestFileId
              : _currentState.fileIdInput,
      sourceLang: LanguageCodes.languages.containsKey(source)
          ? source
          : _currentState.sourceLang,
      targetLang: LanguageCodes.languages.containsKey(target)
          ? target
          : _currentState.targetLang,
    ));
  }

  Future<void> _persistLanguages({
    required String sourceLang,
    required String targetLang,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(StorageKeys.lastSourceLanguage, sourceLang);
    await prefs.setString(StorageKeys.lastTargetLanguage, targetLang);
  }

  void updateFileId(String value) {
    _updateState(_currentState.copyWith(
      fileIdInput: value,
      fileIdError: null,
      creationError: null,
    ));
  }

  Future<void> updateSourceLang(String code) async {
    final previousTarget = _currentState.targetLang;
    _updateState(_currentState.copyWith(
      sourceLang: code,
      creationError: null,
    ));
    await _persistLanguages(
      sourceLang: code,
      targetLang: previousTarget,
    );
  }

  Future<void> updateTargetLang(String code) async {
    final previousSource = _currentState.sourceLang;
    _updateState(_currentState.copyWith(
      targetLang: code,
      creationError: null,
    ));
    await _persistLanguages(
      sourceLang: previousSource,
      targetLang: code,
    );
  }

  void updateJobStatusId(String value) {
    _updateState(_currentState.copyWith(
      jobStatusIdInput: value,
      jobStatusIdError: null,
      statusError: null,
    ));
  }

  Future<void> createTranslationJob() async {
    final currentState = _currentState;
    final fileId = currentState.fileIdInput.trim();

    if (fileId.isEmpty) {
      _updateState(currentState.copyWith(
        fileIdError: 'Enter a file ID before creating a translation job.',
      ));
      return;
    }

    if (currentState.sourceLang == currentState.targetLang) {
      _updateState(currentState.copyWith(
        creationError: 'Choose different source and target languages.',
      ));
      return;
    }

    _updateState(currentState.copyWith(
      isCreatingJob: true,
      fileIdError: null,
      creationError: null,
    ));

    try {
      final response = await _repository.createJob(
        projectId: currentState.currentProjectId,
        fileId: fileId,
        sourceLang: currentState.sourceLang,
        targetLang: currentState.targetLang,
      );

      final bootstrapStatus = TranslationJobStatusResponse(
        signal: response.signal,
        job: TranslationJobStatusDetails(
          jobId: response.jobId,
          status: response.status,
        ),
      );

      _updateState(_currentState.copyWith(
        isCreatingJob: false,
        createdJobResponse: response,
        creationError: null,
        jobStatusIdInput: '',
        jobStatusIdError: null,
        jobStatusResponse: bootstrapStatus,
        statusError: null,
        lastRefreshTime: null,
      ));

      if (_currentState.autoRefreshEnabled) {
        _startAutoRefresh(response.jobId);
      }
    } catch (error) {
      _updateState(_currentState.copyWith(
        isCreatingJob: false,
        creationError: error.toString(),
      ));
    }
  }

  Future<void> checkJobStatus() async {
    final currentState = _currentState;
    final jobId = currentState.resolvedJobId;

    if (jobId == null || jobId.isEmpty) {
      _updateState(currentState.copyWith(
        jobStatusIdError: 'Enter a job ID or create a translation job first.',
      ));
      return;
    }

    _updateState(currentState.copyWith(
      isCheckingStatus: true,
      jobStatusIdError: null,
      statusError: null,
    ));

    try {
      final response = await _repository.getJobStatus(jobId: jobId);
      _applyStatusResponse(response);

      if (_currentState.autoRefreshEnabled &&
          !JobStatus.isCompleted(response.job.status)) {
        _startAutoRefresh(jobId);
      }
    } catch (error) {
      _updateState(_currentState.copyWith(
        isCheckingStatus: false,
        statusError: error.toString(),
      ));
    }
  }

  void toggleAutoRefresh(bool enabled) {
    if (!enabled) {
      _stopAutoRefresh(updateState: true);
      return;
    }

    final jobId = _currentState.resolvedJobId;
    if (jobId == null || jobId.isEmpty) {
      _updateState(_currentState.copyWith(
        statusError: 'Create a job or enter a job ID before enabling auto-refresh.',
        autoRefreshEnabled: false,
      ));
      return;
    }

    _updateState(_currentState.copyWith(
      autoRefreshEnabled: true,
      statusError: null,
    ));
    _startAutoRefresh(jobId);
  }

  void updateRefreshInterval(int seconds) {
    final normalized = seconds.clamp(1, 30).toInt();
    _updateState(_currentState.copyWith(
      refreshIntervalSeconds: normalized,
    ));

    if (_currentState.autoRefreshEnabled) {
      final jobId = _currentState.resolvedJobId;
      if (jobId != null && jobId.isNotEmpty) {
        _startAutoRefresh(jobId);
      }
    }
  }

  void clearJob() {
    _stopAutoRefresh(updateState: false);
    _repository.clearTrackedJob();
    _updateState(_currentState.copyWith(
      createdJobResponse: null,
      creationError: null,
      jobStatusIdInput: '',
      jobStatusIdError: null,
      jobStatusResponse: null,
      statusError: null,
      autoRefreshEnabled: false,
      lastRefreshTime: null,
      isDownloading: false,
      downloadError: null,
      lastDownloadedPath: null,
    ));
  }

  Future<String?> downloadResultFile() async {
    final currentState = _currentState;
    final job = currentState.jobStatusResponse?.job;
    final status = job?.status ?? currentState.createdJobResponse?.status;
    if (status == null || status.toLowerCase() != JobStatus.completed) {
      _updateState(currentState.copyWith(
        downloadError: 'Translation job is not completed yet.',
      ));
      return null;
    }

    final jobIdString = currentState.resolvedJobId;
    final jobId = jobIdString == null ? null : int.tryParse(jobIdString);
    if (jobId == null || jobId <= 0) {
      _updateState(currentState.copyWith(
        downloadError: 'Invalid job ID for download.',
      ));
      return null;
    }

    if (currentState.isDownloading) {
      return currentState.lastDownloadedPath;
    }

    _updateState(currentState.copyWith(
      isDownloading: true,
      downloadError: null,
      lastDownloadedPath: null,
    ));

    try {
      final download = await _repository.downloadTranslatedFile(jobId: jobId);
      final dir = await getApplicationDocumentsDirectory();

      final rawName =
          (download.filename?.trim().isNotEmpty ?? false)
              ? download.filename!.trim()
              : 'translated_$jobId.bin';
      final safeName = _sanitizeFileName(rawName);
      final outPath = p.join(dir.path, safeName);

      final outFile = File(outPath);
      await outFile.writeAsBytes(download.bytes, flush: true);

      _updateState(_currentState.copyWith(
        isDownloading: false,
        downloadError: null,
        lastDownloadedPath: outPath,
      ));

      await OpenFilex.open(outPath);
      return outPath;
    } catch (e) {
      _updateState(_currentState.copyWith(
        isDownloading: false,
        downloadError: e.toString(),
      ));
      return null;
    }
  }

  String _sanitizeFileName(String name) {
    var result = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (result.isEmpty) {
      result = 'download.bin';
    }
    return result;
  }

  void _applyStatusResponse(TranslationJobStatusResponse response) {
    final terminal = JobStatus.isCompleted(response.job.status);
    if (terminal) {
      _pollingSubscription?.cancel();
      _pollingSubscription = null;
    }

    _updateState(_currentState.copyWith(
      isCheckingStatus: false,
      jobStatusResponse: response,
      statusError: null,
      lastRefreshTime: DateTime.now(),
      autoRefreshEnabled: terminal ? false : _currentState.autoRefreshEnabled,
      downloadError: null,
    ));
  }

  void _startAutoRefresh(String jobId) {
    _pollingSubscription?.cancel();
    _pollingSubscription = _repository
        .pollJobStatus(
          jobId: jobId,
          interval: Duration(seconds: _currentState.refreshIntervalSeconds),
        )
        .listen(
      _applyStatusResponse,
      onError: (Object error, StackTrace stackTrace) {
        _pollingSubscription?.cancel();
        _pollingSubscription = null;
        _updateState(_currentState.copyWith(
          isCheckingStatus: false,
          statusError: error.toString(),
          autoRefreshEnabled: false,
        ));
      },
    );
  }

  void _stopAutoRefresh({required bool updateState}) {
    _pollingSubscription?.cancel();
    _pollingSubscription = null;
    if (updateState) {
      _updateState(_currentState.copyWith(autoRefreshEnabled: false));
    }
  }
}
