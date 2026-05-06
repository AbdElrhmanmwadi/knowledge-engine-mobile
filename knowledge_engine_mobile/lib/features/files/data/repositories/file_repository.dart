import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/api_response_base.dart';
import '../../../../core/models/index_push_response.dart';
import '../../../../core/models/process_response.dart';
import '../../../../core/models/upload_response.dart';
import '../../../../core/network/api_service.dart';

/// Repository wrapper for file-related API operations.
class FileRepository {
  FileRepository({
    ApiService? apiService,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;

  String? _currentFileId;
  int _lastChunkSize = AppConfig.defaultChunkSize;
  int _lastOverlapSize = AppConfig.defaultOverlapSize;
  bool _lastResetFlag = false;
  JsonMap? _lastIndexInfo;

  String? get currentFileId => _currentFileId;
  int get lastChunkSize => _lastChunkSize;
  int get lastOverlapSize => _lastOverlapSize;
  bool get lastResetFlag => _lastResetFlag;
  JsonMap? get lastIndexInfo => _lastIndexInfo;

  Future<UploadResponse> uploadFile({
    required int projectId,
    required File file,
    ProgressCallback? onProgress,
  }) async {
    final response = await _apiService.uploadFile(
      projectId: projectId,
      file: file,
      onProgress: onProgress,
    );

    _currentFileId = response.fileId;
    return response;
  }

  Future<ProcessResponse> processFile({
    required int projectId,
    required String fileId,
    int chunkSize = AppConfig.defaultChunkSize,
    int overlapSize = AppConfig.defaultOverlapSize,
    bool doReset = false,
  }) async {
    final response = await _apiService.processFile(
      projectId: projectId,
      fileId: fileId,
      chunkSize: chunkSize,
      overlapSize: overlapSize,
      doReset: doReset,
    );

    _currentFileId = response.fileId ?? fileId;
    _lastChunkSize = chunkSize;
    _lastOverlapSize = overlapSize;
    _lastResetFlag = doReset;
    return response;
  }

  Future<IndexPushResponse> pushIndex({
    required int projectId,
    bool doReset = false,
  }) async {
    _lastResetFlag = doReset;
    return _apiService.pushIndex(
      projectId: projectId,
      doReset: doReset,
    );
  }

  Future<JsonMap> getIndexInfo({
    required int projectId,
  }) async {
    final response = await _apiService.getIndexInfo(projectId: projectId);
    _lastIndexInfo = response;
    return response;
  }

  void clearCurrentFile() {
    _currentFileId = null;
  }
}
