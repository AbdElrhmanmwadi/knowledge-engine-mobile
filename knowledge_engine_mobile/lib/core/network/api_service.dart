import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../config/constants.dart';
import '../models/api_response_base.dart';
import '../models/index_push_response.dart';
import '../models/process_response.dart';
import '../models/rag_answer_response.dart';
import '../models/search_response.dart';
import '../models/translation_job_create_response.dart';
import '../models/translation_job_status_response.dart';
import '../models/upload_response.dart';
import 'api_exception.dart';
import 'dio_client.dart';

typedef JsonParser<T> = T Function(JsonMap json);

/// Centralized abstraction for all backend communication.
abstract class ApiService {
  Future<UploadResponse> uploadFile({
    required int projectId,
    required File file,
    ProgressCallback? onProgress,
  });

  Future<JsonMap> deleteAllProjectFiles({
    required int projectId,
  });

  Future<ProcessResponse> processFile({
    required int projectId,
    required String fileId,
    int chunkSize = AppConfig.defaultChunkSize,
    int overlapSize = AppConfig.defaultOverlapSize,
    bool doReset = false,
  });

  Future<IndexPushResponse> pushIndex({
    required int projectId,
    bool doReset = false,
  });

  Future<JsonMap> getIndexInfo({
    required int projectId,
  });

  Future<SearchResponse> search({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultSearchLimit,
  });

  Future<RagAnswerResponse> askQuestion({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultRagLimit,
  });

  Future<TranslationJobCreateResponse> createTranslationJob({
    required int projectId,
    required String fileId,
    required String sourceLang,
    required String targetLang,
  });

  Future<TranslationJobStatusResponse> getTranslationStatus({
    required String jobId,
  });
}

/// Dio-based implementation of [ApiService].
class DioApiService implements ApiService {
  DioApiService({
    Dio? dio,
  }) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  @override
  Future<JsonMap> deleteAllProjectFiles({
    required int projectId,
  }) {
    return _delete(
      path: ApiConstants.deleteAllProjectFiles(projectId),
      parser: (JsonMap json) => json,
      operation: 'delete project',
      requireSuccessSignal: true,
      validateSignalIfPresent: true,
    );
  }

  @override
  Future<UploadResponse> uploadFile({
    required int projectId,
    required File file,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(
        file.path,
        filename: _resolveFileName(file),
      ),
    });

    return _post(
      path: ApiConstants.uploadFile(projectId),
      data: formData,
      onSendProgress: onProgress,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: Duration(seconds: AppConfig.uploadTimeout),
        receiveTimeout: Duration(seconds: AppConfig.uploadTimeout),
      ),
      parser: UploadResponse.fromJson,
      operation: 'upload file',
    );
  }

  @override
  Future<ProcessResponse> processFile({
    required int projectId,
    required String fileId,
    int chunkSize = AppConfig.defaultChunkSize,
    int overlapSize = AppConfig.defaultOverlapSize,
    bool doReset = false,
  }) {
    return _post(
      path: ApiConstants.processFile(projectId),
      data: <String, dynamic>{
        'file_id': fileId,
        'chunk_size': chunkSize,
        'overlap_size': overlapSize,
        'do_reset': doReset,
      },
      parser: ProcessResponse.fromJson,
      operation: 'process file',
    );
  }

  @override
  Future<IndexPushResponse> pushIndex({
    required int projectId,
    bool doReset = false,
  }) {
    return _post(
      path: ApiConstants.pushIndex(projectId),
      data: <String, dynamic>{
        'do_reset': doReset,
      },
      parser: IndexPushResponse.fromJson,
      operation: 'push index',
    );
  }

  @override
  Future<JsonMap> getIndexInfo({
    required int projectId,
  }) {
    return _get(
      path: ApiConstants.getIndexInfo(projectId),
      parser: (JsonMap json) => json,
      operation: 'get index info',
      requireSuccessSignal: false,
      validateSignalIfPresent: true,
    );
  }

  @override
  Future<SearchResponse> search({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultSearchLimit,
  }) {
    return _post(
      path: ApiConstants.searchIndex(projectId),
      data: <String, dynamic>{
        'text': text,
        'limit': limit,
      },
      parser: SearchResponse.fromJson,
      operation: 'search index',
    );
  }

  @override
  Future<RagAnswerResponse> askQuestion({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultRagLimit,
  }) {
    return _post(
      path: ApiConstants.answerQuestion(projectId),
      data: <String, dynamic>{
        'text': text,
        'limit': limit,
      },
      parser: RagAnswerResponse.fromJson,
      operation: 'ask question',
    );
  }

  @override
  Future<TranslationJobCreateResponse> createTranslationJob({
    required int projectId,
    required String fileId,
    required String sourceLang,
    required String targetLang,
  }) {
    return _post(
      path: ApiConstants.createTranslationJob,
      data: <String, dynamic>{
        'project_id': projectId,
        'file_id': fileId,
        'source_lang': sourceLang,
        'target_lang': targetLang,
      },
      parser: TranslationJobCreateResponse.fromJson,
      operation: 'create translation job',
    );
  }

  @override
  Future<TranslationJobStatusResponse> getTranslationStatus({
    required String jobId,
  }) {
    return _get(
      path: ApiConstants.getTranslationStatus(jobId),
      parser: TranslationJobStatusResponse.fromJson,
      operation: 'get translation status',
    );
  }

  Future<T> _get<T>({
    required String path,
    required JsonParser<T> parser,
    required String operation,
    bool requireSuccessSignal = true,
    bool validateSignalIfPresent = false,
  }) {
    return _executeRequest(
      request: () => _dio.get<dynamic>(path),
      parser: parser,
      operation: operation,
      requireSuccessSignal: requireSuccessSignal,
      validateSignalIfPresent: validateSignalIfPresent,
    );
  }

  Future<T> _post<T>({
    required String path,
    required JsonParser<T> parser,
    required String operation,
    Object? data,
    ProgressCallback? onSendProgress,
    Options? options,
    bool requireSuccessSignal = true,
    bool validateSignalIfPresent = false,
  }) {
    return _executeRequest(
      request: () => _dio.post<dynamic>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: options,
      ),
      parser: parser,
      operation: operation,
      requireSuccessSignal: requireSuccessSignal,
      validateSignalIfPresent: validateSignalIfPresent,
    );
  }

  Future<T> _delete<T>({
    required String path,
    required JsonParser<T> parser,
    required String operation,
    Object? data,
    Options? options,
    bool requireSuccessSignal = true,
    bool validateSignalIfPresent = false,
  }) {
    return _executeRequest(
      request: () => _dio.delete<dynamic>(
        path,
        data: data,
        options: options,
      ),
      parser: parser,
      operation: operation,
      requireSuccessSignal: requireSuccessSignal,
      validateSignalIfPresent: validateSignalIfPresent,
    );
  }

  Future<T> _executeRequest<T>({
    required Future<Response<dynamic>> Function() request,
    required JsonParser<T> parser,
    required String operation,
    required bool requireSuccessSignal,
    required bool validateSignalIfPresent,
  }) async {
    try {
      final response = await request();
      final json = _normalizeJson(response.data, operation: operation);

      _validateSignal(
        json,
        operation: operation,
        requireSuccessSignal: requireSuccessSignal,
        validateSignalIfPresent: validateSignalIfPresent,
      );

      return parser(json);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error, stackTrace) {
      throw ApiException.parseError(
        message: '$operation: ${error.message}',
        originalException: error,
        stackTrace: stackTrace,
      );
    }
  }

  JsonMap _normalizeJson(
    dynamic data, {
    required String operation,
  }) {
    return ApiResponseBase.normalizeJsonMap(
      data,
      fieldName: '$operation response',
    );
  }

  void _validateSignal(
    JsonMap json, {
    required String operation,
    required bool requireSuccessSignal,
    required bool validateSignalIfPresent,
  }) {
    final hasSignal = json.containsKey('signal');

    if (!requireSuccessSignal && !(validateSignalIfPresent && hasSignal)) {
      return;
    }

    final signal = ApiResponseBase.readRequiredString(json, 'signal');
    if (ApiSignals.isSuccessSignal(signal)) {
      return;
    }

    throw ApiException.backendError(
      message: _extractBackendMessage(json) ?? 'Failed to $operation.',
      code: ApiResponseBase.readOptionalString(json, 'code') ?? signal,
    );
  }

  ApiException _mapDioException(DioException error) {
    final originalError = error.error;
    if (originalError is ApiException) {
      return originalError;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException.timeoutError(
          originalException: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badResponse:
        return ApiException.fromResponse(
          statusCode: error.response?.statusCode ?? 0,
          responseData: error.response?.data,
          originalException: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.connectionError:
        return ApiException.networkError(
          message: 'Failed to connect to the server.',
          originalException: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return ApiException.networkError(
          message: 'SSL certificate error.',
          originalException: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
          originalException: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.unknown:
        return ApiException.unknownError(
          originalException: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  String? _extractBackendMessage(JsonMap json) {
    for (final key in const <String>['message', 'error', 'detail']) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value != null) {
        return value.toString();
      }
    }

    return null;
  }

  String _resolveFileName(File file) {
    final segments = file.uri.pathSegments;
    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }

    return 'upload.bin';
  }
}
