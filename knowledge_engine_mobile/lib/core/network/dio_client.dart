import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../config/app_config.dart';

/// Centralized Dio HTTP client with interceptors and configuration
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;
  late AuthInterceptor _authInterceptor;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _initializeDio();
  }

  Dio get dio => _dio;

  /// Auth interceptor, exposed so the auth state holder can register a
  /// session-expired callback.
  AuthInterceptor get authInterceptor => _authInterceptor;

  /// Initialize Dio with base configuration and interceptors
  void _initializeDio({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.getBaseUrl(),
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _authInterceptor = AuthInterceptor(dioProvider: () => _dio);

    // Add interceptors. Auth goes first so it sees raw 401 responses
    // before the error interceptor wraps them.
    _dio.interceptors.addAll([
      _authInterceptor,
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  /// Update base URL (for custom server configuration)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Get current base URL
  String getBaseUrl() {
    return _dio.options.baseUrl;
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════');
      print('REQUEST: ${options.method} ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      print('═══════════════════════════════════════════════');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════');
      print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      print('Data: ${response.data}');
      print('═══════════════════════════════════════════════');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════');
      print('ERROR: ${err.message}');
      print('Status Code: ${err.response?.statusCode}');
      print('Response: ${err.response?.data}');
      print('═══════════════════════════════════════════════');
    }
    handler.next(err);
  }
}

/// Error interceptor for centralized error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    late ApiException apiException;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      apiException = ApiException.timeoutError(
        originalException: err,
        stackTrace: err.stackTrace,
      );
    } else if (err.type == DioExceptionType.badResponse) {
      apiException = ApiException.fromResponse(
        statusCode: err.response?.statusCode ?? 0,
        responseData: err.response?.data,
        originalException: err,
        stackTrace: err.stackTrace,
      );
    } else if (err.type == DioExceptionType.connectionError) {
      apiException = ApiException.networkError(
        message: 'Failed to connect to the server',
        originalException: err,
        stackTrace: err.stackTrace,
      );
    } else if (err.type == DioExceptionType.badCertificate) {
      apiException = ApiException.networkError(
        message: 'SSL certificate error',
        originalException: err,
        stackTrace: err.stackTrace,
      );
    } else {
      apiException = ApiException.unknownError(
        originalException: err,
        stackTrace: err.stackTrace,
      );
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      response: err.response,
      type: err.type,
      stackTrace: err.stackTrace,
    ));
  }
}

/// Extension methods for easier API calls with error handling
extension DioExtension on Dio {
  /// Wrapper for GET with error handling
  Future<T> getWithErrorHandling<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      rethrow;
    }
  }

  /// Wrapper for POST with error handling
  Future<T> postWithErrorHandling<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      rethrow;
    }
  }
}
