import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';

/// Global authentication status driving the router guards.
enum AuthStatus {
  /// Session restore still in progress (app startup).
  unknown,

  /// Valid session present.
  authenticated,

  /// No session; user must sign in.
  unauthenticated,
}

/// Holds the app-wide auth status and exposes all auth actions.
///
/// Per-action loading/error handling stays local to the pages: action
/// methods throw [AuthFailure] on error, and only the global status lives
/// here so the router can react to sign-in/sign-out.
class AuthNotifier extends Notifier<AuthStatus> {
  final AuthRepository _repository = AuthRepository();

  @override
  AuthStatus build() {
    // Let the network layer end the session when a token refresh is
    // rejected (e.g. refresh token revoked server-side).
    DioClient().authInterceptor.onSessionExpired = _handleSessionExpired;
    Future.microtask(_restoreSession);
    return AuthStatus.unknown;
  }

  /// Auto-login on app start using the stored refresh token.
  Future<void> _restoreSession() async {
    final tokens = await _repository.restoreSession();
    if (state == AuthStatus.unknown) {
      state = tokens != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
  }

  /// Signs in with email/password. Throws [AuthFailure] on error.
  Future<void> login({required String email, required String password}) async {
    await _repository.login(email: email, password: password);
    state = AuthStatus.authenticated;
  }

  /// Signs in with a Google ID token. Throws [AuthFailure] on error.
  Future<void> loginWithGoogle({required String idToken}) async {
    await _repository.loginWithGoogle(idToken: idToken);
    state = AuthStatus.authenticated;
  }

  /// Registers a new account. Returns the backend message
  /// ("Check your email"). Throws [AuthFailure] on error.
  Future<String> register({
    required String email,
    required String username,
    required String password,
  }) {
    return _repository.register(
      email: email,
      username: username,
      password: password,
    );
  }

  /// Verifies an email address with the token from the verification link.
  Future<String> verifyEmail({required String token}) {
    return _repository.verifyEmail(token: token);
  }

  /// Requests a password-reset email. Always resolves with the generic
  /// backend message regardless of account existence.
  Future<String> requestPasswordReset({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }

  /// Resets the password with the token from the reset email. The backend
  /// revokes all refresh tokens, so any active session ends.
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final message = await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    if (state == AuthStatus.authenticated) {
      state = AuthStatus.unauthenticated;
    }
    return message;
  }

  /// Signs out: revokes the refresh token server-side (best effort) and
  /// always clears the local session.
  Future<void> logout() async {
    await _repository.logout();
    state = AuthStatus.unauthenticated;
  }

  void _handleSessionExpired() {
    if (state == AuthStatus.authenticated) {
      state = AuthStatus.unauthenticated;
    }
  }
}

/// Provider for the global auth status and auth actions.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
