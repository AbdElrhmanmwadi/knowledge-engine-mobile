import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/index_push_response.dart';
import '../../../../core/models/process_response.dart';
import '../../../../core/models/upload_response.dart';
import '../../data/repositories/file_repository.dart';

enum StatusLogKind { info, success, error }

class StatusLogEntry {
  const StatusLogEntry({
    required this.timestamp,
    required this.message,
    required this.kind,
  });

  final DateTime timestamp;
  final String message;
  final StatusLogKind kind;

  String get status {
    switch (kind) {
      case StatusLogKind.info:
        return 'pending';
      case StatusLogKind.success:
        return ApiSignals.success;
      case StatusLogKind.error:
        return ApiSignals.error;
    }
  }

  String get label {
    switch (kind) {
      case StatusLogKind.info:
        return 'Info';
      case StatusLogKind.success:
        return 'Success';
      case StatusLogKind.error:
        return 'Error';
    }
  }
}

class FilesState {
  const FilesState({
    required this.currentProjectId,
    this.selectedFile,
    this.selectedFileName,
    this.fileId,
    this.uploadProgress = 0,
    this.isUploading = false,
    this.chunkSize = AppConfig.defaultChunkSize,
    this.overlapSize = AppConfig.defaultOverlapSize,
    this.processDoReset = false,
    this.indexDoReset = false,
    this.showAdvancedOptions = false,
    this.isProcessing = false,
    this.processResponse,
    this.isIndexing = false,
    this.indexResponse,
    this.statusLog = const <StatusLogEntry>[],
    this.errorMessage,
    this.chunkSizeError,
    this.overlapSizeError,
  });

  factory FilesState.initial(int projectId) {
    return FilesState(currentProjectId: projectId);
  }

  final int currentProjectId;
  final File? selectedFile;
  final String? selectedFileName;
  final String? fileId;
  final double uploadProgress;
  final bool isUploading;
  final int chunkSize;
  final int overlapSize;
  final bool processDoReset;
  final bool indexDoReset;
  final bool showAdvancedOptions;
  final bool isProcessing;
  final ProcessResponse? processResponse;
  final bool isIndexing;
  final IndexPushResponse? indexResponse;
  final List<StatusLogEntry> statusLog;
  final String? errorMessage;
  final String? chunkSizeError;
  final String? overlapSizeError;

  bool get isBusy => isUploading || isProcessing || isIndexing;
  bool get canUpload => selectedFile != null && !isBusy;
  bool get canProcess => fileId != null && !isBusy;
  bool get canIndex => processResponse != null && !isBusy;

  String? get activeLoadingMessage {
    if (isUploading) {
      return 'Uploading file...';
    }
    if (isProcessing) {
      return 'Processing file...';
    }
    if (isIndexing) {
      return 'Pushing chunks to the vector index...';
    }
    return null;
  }

  static const Object _unset = Object();

  FilesState copyWith({
    Object? selectedFile = _unset,
    Object? selectedFileName = _unset,
    Object? fileId = _unset,
    double? uploadProgress,
    bool? isUploading,
    int? chunkSize,
    int? overlapSize,
    bool? processDoReset,
    bool? indexDoReset,
    bool? showAdvancedOptions,
    bool? isProcessing,
    Object? processResponse = _unset,
    bool? isIndexing,
    Object? indexResponse = _unset,
    List<StatusLogEntry>? statusLog,
    Object? errorMessage = _unset,
    Object? chunkSizeError = _unset,
    Object? overlapSizeError = _unset,
  }) {
    return FilesState(
      currentProjectId: currentProjectId,
      selectedFile: identical(selectedFile, _unset)
          ? this.selectedFile
          : selectedFile as File?,
      selectedFileName: identical(selectedFileName, _unset)
          ? this.selectedFileName
          : selectedFileName as String?,
      fileId: identical(fileId, _unset) ? this.fileId : fileId as String?,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploading: isUploading ?? this.isUploading,
      chunkSize: chunkSize ?? this.chunkSize,
      overlapSize: overlapSize ?? this.overlapSize,
      processDoReset: processDoReset ?? this.processDoReset,
      indexDoReset: indexDoReset ?? this.indexDoReset,
      showAdvancedOptions: showAdvancedOptions ?? this.showAdvancedOptions,
      isProcessing: isProcessing ?? this.isProcessing,
      processResponse: identical(processResponse, _unset)
          ? this.processResponse
          : processResponse as ProcessResponse?,
      isIndexing: isIndexing ?? this.isIndexing,
      indexResponse: identical(indexResponse, _unset)
          ? this.indexResponse
          : indexResponse as IndexPushResponse?,
      statusLog: statusLog ?? this.statusLog,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      chunkSizeError: identical(chunkSizeError, _unset)
          ? this.chunkSizeError
          : chunkSizeError as String?,
      overlapSizeError: identical(overlapSizeError, _unset)
          ? this.overlapSizeError
          : overlapSizeError as String?,
    );
  }
}

class FilesNotifier extends AsyncNotifier<FilesState> {
  FilesNotifier(this._projectId);

  final int _projectId;
  late FileRepository _repository;
  SharedPreferences? _prefs;

  @override
  FilesState build() {
    _repository = FileRepository();
    _warmSharedPreferences();
    return FilesState.initial(_projectId);
  }

  FilesState get _currentState =>
      state.maybeWhen(data: (value) => value, orElse: () => FilesState.initial(_projectId));

  void _updateState(FilesState nextState) {
    state = AsyncValue.data(nextState);
  }

  Future<void> selectFile() async {
    clearError();
    _addToLog('Opening file picker...', StatusLogKind.info);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: SupportedFileTypes.extensions
            .map((extension) => extension.replaceFirst('.', ''))
            .toList(),
      );

      if (result == null || result.files.isEmpty) {
        _addToLog('File selection cancelled.', StatusLogKind.info);
        return;
      }

      final pickedFile = result.files.single;
      final path = pickedFile.path;
      if (path == null || path.isEmpty) {
        _setError('The selected file path is not available on this device.');
        _addToLog(
          'Selected file does not expose a readable path.',
          StatusLogKind.error,
        );
        return;
      }

      if (!SupportedFileTypes.isSupported(pickedFile.name)) {
        _setError(
          'Unsupported file type. Please choose one of the listed formats.',
        );
        _addToLog(
          'Rejected unsupported file type for ${pickedFile.name}.',
          StatusLogKind.error,
        );
        return;
      }

      _repository.clearCurrentFile();
      _updateState(_currentState.copyWith(
        selectedFile: File(path),
        selectedFileName: pickedFile.name,
        fileId: null,
        uploadProgress: 0,
        processResponse: null,
        indexResponse: null,
        errorMessage: null,
      ));
      _addToLog('Selected file ${pickedFile.name}.', StatusLogKind.success);
    } catch (error) {
      _setError('Failed to open the file picker.');
      _addToLog('File picker failed: $error', StatusLogKind.error);
    }
  }

  Future<void> uploadFile() async {
    final currentState = _currentState;
    final selectedFile = currentState.selectedFile;
    final selectedFileName = currentState.selectedFileName;

    if (selectedFile == null || selectedFileName == null) {
      _setError('Choose a file before uploading.');
      _addToLog(
        'Upload blocked because no file is selected.',
        StatusLogKind.error,
      );
      return;
    }

    _updateState(currentState.copyWith(
      isUploading: true,
      uploadProgress: 0,
      fileId: null,
      processResponse: null,
      indexResponse: null,
      errorMessage: null,
    ));
    _addToLog('Uploading $selectedFileName...', StatusLogKind.info);

    try {
      final response = await _repository.uploadFile(
        projectId: currentState.currentProjectId,
        file: selectedFile,
        onProgress: (sent, total) {
          if (total <= 0) {
            return;
          }

          final progress = (sent / total).clamp(0.0, 1.0).toDouble();
          _updateState(_currentState.copyWith(uploadProgress: progress));
        },
      );

      _handleUploadSuccess(response, selectedFileName);
    } catch (error) {
      _updateState(_currentState.copyWith(
        isUploading: false,
        uploadProgress: 0,
        errorMessage: error.toString(),
      ));
      _addToLog('Upload failed: $error', StatusLogKind.error);
    }
  }

  Future<void> processFile() async {
    clearError();
    final currentState = _currentState;
    final fileId = currentState.fileId;

    if (fileId == null || fileId.isEmpty) {
      _setError('Upload a file first to get a file ID.');
      _addToLog(
        'Processing blocked because no file ID is available.',
        StatusLogKind.error,
      );
      return;
    }

    if (!_validateParameters()) {
      _addToLog(
        'Processing blocked because parameters are invalid.',
        StatusLogKind.error,
      );
      return;
    }

    _updateState(_currentState.copyWith(
      isProcessing: true,
      indexResponse: null,
      errorMessage: null,
    ));
    _addToLog(
      'Processing file $fileId with chunk size ${currentState.chunkSize}, overlap ${currentState.overlapSize}, reset ${currentState.processDoReset}.',
      StatusLogKind.info,
    );

    try {
      final response = await _repository.processFile(
        projectId: currentState.currentProjectId,
        fileId: fileId,
        chunkSize: currentState.chunkSize,
        overlapSize: currentState.overlapSize,
        doReset: currentState.processDoReset,
      );

      _updateState(_currentState.copyWith(
        isProcessing: false,
        processResponse: response,
        errorMessage: null,
      ));
      _addToLog(
        'Processing completed: ${response.insertedChunks} chunks inserted across ${response.processedFiles} processed files.',
        StatusLogKind.success,
      );
    } catch (error) {
      _updateState(_currentState.copyWith(
        isProcessing: false,
        errorMessage: error.toString(),
      ));
      _addToLog('Processing failed: $error', StatusLogKind.error);
    }
  }

  Future<void> pushIndex() async {
    clearError();
    final currentState = _currentState;

    if (currentState.processResponse == null) {
      _setError('Process the file before pushing chunks to the index.');
      _addToLog(
        'Index push blocked because no processed file is available.',
        StatusLogKind.error,
      );
      return;
    }

    _updateState(currentState.copyWith(
      isIndexing: true,
      errorMessage: null,
    ));
    _addToLog(
      'Pushing chunks to the index. Full reindex: ${currentState.indexDoReset}.',
      StatusLogKind.info,
    );

    try {
      final response = await _repository.pushIndex(
        projectId: currentState.currentProjectId,
        doReset: currentState.indexDoReset,
      );

      _updateState(_currentState.copyWith(
        isIndexing: false,
        indexResponse: response,
        errorMessage: null,
      ));

      if (response.indexedCount != null) {
        _addToLog(
          'Index push completed successfully with ${response.indexedCount} indexed chunks.',
          StatusLogKind.success,
        );
      } else {
        _addToLog(
          'Index push completed successfully.',
          StatusLogKind.success,
        );
      }
    } catch (error) {
      _updateState(_currentState.copyWith(
        isIndexing: false,
        errorMessage: error.toString(),
      ));
      _addToLog('Index push failed: $error', StatusLogKind.error);
    }
  }

  void updateChunkSize(String value) {
    clearError();
    final parsed = int.tryParse(value.trim());

    if (parsed == null) {
      _updateState(_currentState.copyWith(
        chunkSizeError: 'Chunk size must be a number.',
      ));
      return;
    }

    if (parsed < ValidationConstants.minChunkSize ||
        parsed > ValidationConstants.maxChunkSize) {
      _updateState(_currentState.copyWith(
        chunkSizeError:
            'Chunk size must be between ${ValidationConstants.minChunkSize} and ${ValidationConstants.maxChunkSize}.',
      ));
      return;
    }

    _updateState(_currentState.copyWith(
      chunkSize: parsed,
      chunkSizeError: null,
    ));
  }

  void updateOverlapSize(String value) {
    clearError();
    final parsed = int.tryParse(value.trim());

    if (parsed == null) {
      _updateState(_currentState.copyWith(
        overlapSizeError: 'Overlap size must be a number.',
      ));
      return;
    }

    if (parsed < ValidationConstants.minOverlapSize ||
        parsed > ValidationConstants.maxOverlapSize) {
      _updateState(_currentState.copyWith(
        overlapSizeError:
            'Overlap size must be between ${ValidationConstants.minOverlapSize} and ${ValidationConstants.maxOverlapSize}.',
      ));
      return;
    }

    _updateState(_currentState.copyWith(
      overlapSize: parsed,
      overlapSizeError: null,
    ));
  }

  void toggleAdvancedOptions(bool value) {
    _updateState(_currentState.copyWith(showAdvancedOptions: value));
  }

  void toggleProcessDoReset(bool value) {
    _updateState(_currentState.copyWith(processDoReset: value));
  }

  void toggleIndexDoReset(bool value) {
    _updateState(_currentState.copyWith(indexDoReset: value));
  }

  void clearStatus() {
    _updateState(_currentState.copyWith(statusLog: const <StatusLogEntry>[]));
  }

  void clearError() {
    _updateState(_currentState.copyWith(errorMessage: null));
  }

  void _handleUploadSuccess(UploadResponse response, String fileName) {
    _updateState(_currentState.copyWith(
      isUploading: false,
      uploadProgress: 1,
      fileId: response.fileId,
      errorMessage: null,
    ));
    _persistLatestFileId(response.fileId);
    _addToLog('Upload completed for $fileName.', StatusLogKind.success);
    _addToLog('Received file ID: ${response.fileId}.', StatusLogKind.success);
  }

  Future<void> _warmSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _persistLatestFileId(String fileId) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(
      StorageKeys.latestFileIdForProject(_projectId),
      fileId,
    );
  }

  bool _validateParameters() {
    final currentState = _currentState;
    final chunkValid =
        currentState.chunkSize >= ValidationConstants.minChunkSize &&
            currentState.chunkSize <= ValidationConstants.maxChunkSize;
    final overlapValid =
        currentState.overlapSize >= ValidationConstants.minOverlapSize &&
            currentState.overlapSize <= ValidationConstants.maxOverlapSize;

    _updateState(currentState.copyWith(
      chunkSizeError: chunkValid
          ? null
          : 'Chunk size must be between ${ValidationConstants.minChunkSize} and ${ValidationConstants.maxChunkSize}.',
      overlapSizeError: overlapValid
          ? null
          : 'Overlap size must be between ${ValidationConstants.minOverlapSize} and ${ValidationConstants.maxOverlapSize}.',
    ));

    if (!chunkValid || !overlapValid) {
      _setError('Please correct the processing parameters and try again.');
    }

    return chunkValid && overlapValid;
  }

  void _setError(String message) {
    _updateState(_currentState.copyWith(errorMessage: message));
  }

  void _addToLog(String message, StatusLogKind kind) {
    final nextLog = List<StatusLogEntry>.from(_currentState.statusLog)
      ..add(
        StatusLogEntry(
          timestamp: DateTime.now(),
          message: message,
          kind: kind,
        ),
      );

    if (nextLog.length > 50) {
      nextLog.removeRange(0, nextLog.length - 50);
    }

    _updateState(_currentState.copyWith(statusLog: nextLog));
  }
}
