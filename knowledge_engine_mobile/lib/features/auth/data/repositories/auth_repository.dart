import 'package:dio/dio.dart';

import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_failure.dart';
import '../models/auth_tokens.dart';

/// Repository for all /auth backend endpoints.
class AuthRepository {
  AuthRepository({
    Dio? dio,
    AuthTokenStorage? tokenStorage,
  })  : _dio = dio ?? DioClient().dio,
        _tokenStorage = tokenStorage ?? const AuthTokenStorage();

  final Dio _dio;
  final AuthTokenStorage _tokenStorage;

  /// POST /auth/register — returns the backend confirmation message.
  Future<String> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final json = await _request(
      () => _dio.post<dynamic>(
        AuthConstants.register,
        data: <String, dynamic>{
          'email': email,
          'username': username,
          'password': password,
        },
      ),
    );
    return _readMessage(json) ?? 'Check your email';
  }

  /// POST /auth/login — stores and returns the token pair.
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final json = await _request(
      () => _dio.post<dynamic>(
        AuthConstants.login,
        data: <String, dynamic>{
          'email': email,
          'password': password,
        },
      ),
    );
    return _persistTokens(json);
  }

  /// POST /auth/google — exchanges a Google ID token for app tokens.
  Future<AuthTokens> loginWithGoogle({required String idToken}) async {
    final json = await _request(
      () => _dio.post<dynamic>(
        AuthConstants.googleLogin,
        data: <String, dynamic>{'id_token': idToken},
      ),
    );
    return _persistTokens(json);
  }

  /// GET /auth/verify-email?token=... — returns the backend message.
  Future<String> verifyEmail({required String token}) async {
    final json = await _request(
      () => _dio.get<dynamic>(
        AuthConstants.verifyEmail,
        queryParameters: <String, dynamic>{'token': token},
      ),
    );
    return _readMessage(json) ?? 'Email verified successfully';
  }

  /// POST /auth/request-password-reset — always succeeds with a generic
  /// message regardless of whether the account exists.
  Future<String> requestPasswordReset({required String email}) async {
    final json = await _request(
      () => _dio.post<dynamic>(
        AuthConstants.requestPasswordReset,
        data: <String, dynamic>{'email': email},
      ),
    );
    return _readMessage(json) ??
        'If an account with that email exists, a password reset link has been sent';
  }

  /// POST /auth/reset-password — on success the backend revokes all refresh
  /// tokens, so local tokens are cleared as well.
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final json = await _request(
      () => _dio.post<dynamic>(
        AuthConstants.resetPassword,
        data: <String, dynamic>{
          'token': token,
          'new_password': newPassword,
        },
      ),
    );
    await _tokenStorage.clear();
    return _readMessage(json) ?? 'Password has been reset successfully';
  }

  /// Restores a previous session on app start.
  ///
  /// Exchanges the stored refresh token for a fresh pair. On an auth
  /// rejection the session is cleared; on a network/server error the stored
  /// tokens are kept so the user stays signed in while offline.
  Future<AuthTokens?> restoreSession() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final json = await _request(
        () => _dio.post<dynamic>(
          AuthConstants.refreshToken,
          data: <String, dynamic>{'refresh_token': refreshToken},
        ),
      );
      return _persistTokens(json);
    } on AuthFailure catch (failure) {
      if (failure.isNetworkError) {
        final accessToken = await _tokenStorage.readAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return null;
      }
      await _tokenStorage.clear();
      return null;
    }
  }

  /// POST /auth/logout — clears local tokens even if the backend call fails.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post<dynamic>(
          AuthConstants.logout,
          data: <String, dynamic>{'refresh_token': refreshToken},
        );
      } catch (_) {
        // Local sign-out must always succeed.
      }
    }
    await _tokenStorage.clear();
  }

  Future<AuthTokens> _persistTokens(Map<String, dynamic> json) async {
    final AuthTokens tokens;
    try {
      tokens = AuthTokens.fromJson(json);
    } on FormatException catch (error) {
      throw AuthFailure(message: error.message);
    }
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  AuthFailure _mapError(DioException error) {
    final statusCode = error.response?.statusCode;
    final wrapped = error.error;

    String? message;
    final data = error.response?.data;
    if (data is Map) {
      for (final key in const <String>['detail', 'message', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          message = value;
          break;
        }
      }
    }
    message ??= wrapped is ApiException ? wrapped.message : error.message;

    return AuthFailure(
      message: message ?? 'Authentication request failed',
      statusCode: statusCode,
    );
  }

  String? _readMessage(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return null;
  }
}
