import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/auth_token_storage.dart';
import '../config/constants.dart';

/// Attaches `Authorization: Bearer <access_token>` to protected requests and
/// transparently refreshes the access token once when a request fails with
/// 401, then retries the original request.
///
/// Refresh is single-flight: concurrent 401s share one refresh call. A
/// request is retried at most once (tracked via [RequestOptions.extra]) so
/// refresh loops are impossible. When refresh is rejected by the backend the
/// stored session is cleared and [onSessionExpired] is invoked so the app can
/// route back to the login screen.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio Function() dioProvider,
    AuthTokenStorage? tokenStorage,
  })  : _dioProvider = dioProvider,
        _tokenStorage = tokenStorage ?? const AuthTokenStorage();

  static const String _retriedFlag = 'auth_retried';

  final Dio Function() _dioProvider;
  final AuthTokenStorage _tokenStorage;

  /// Set by the auth state holder; called when a session can no longer be
  /// refreshed and the user must sign in again.
  void Function()? onSessionExpired;

  /// In-flight refresh shared by concurrent 401 handlers.
  Future<String?>? _refreshing;

  bool _isAuthPath(String path) =>
      path.startsWith('${AuthConstants.authPath}/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path) || options.path == AuthConstants.logout) {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isExpiredAccessToken = err.response?.statusCode == 401 &&
        !_isAuthPath(options.path) &&
        options.extra[_retriedFlag] != true;

    if (!isExpiredAccessToken) {
      handler.next(err);
      return;
    }

    final String? newAccessToken;
    try {
      newAccessToken = await (_refreshing ??= _refreshTokens());
    } finally {
      _refreshing = null;
    }

    if (newAccessToken == null) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = options
        ..extra[_retriedFlag] = true
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dioProvider().fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.reject(retryError);
    }
  }

  /// Exchanges the stored refresh token for a new pair.
  ///
  /// Returns the new access token, or null when the session is gone. The
  /// refresh request goes through the main Dio so logging applies; its path
  /// is an auth path, so it can never trigger another refresh.
  Future<String?> _refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      return null;
    }

    try {
      final response = await _dioProvider().post<dynamic>(
        AuthConstants.refreshToken,
        data: <String, dynamic>{'refresh_token': refreshToken},
      );

      final data = response.data;
      final newAccessToken = data is Map ? data['access_token'] : null;
      final newRefreshToken = data is Map ? data['refresh_token'] : null;
      if (newAccessToken is! String ||
          newAccessToken.isEmpty ||
          newRefreshToken is! String ||
          newRefreshToken.isEmpty) {
        await _expireSession();
        return null;
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return newAccessToken;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        // The backend rejected the refresh token; session is over.
        await _expireSession();
      }
      // Network errors keep the session: the original 401 still surfaces.
      return null;
    }
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    onSessionExpired?.call();
  }
}
