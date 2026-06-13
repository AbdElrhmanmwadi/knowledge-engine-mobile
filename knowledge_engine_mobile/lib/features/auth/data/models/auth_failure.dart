/// Failure raised by auth operations, carrying the HTTP status code so the
/// UI can map it to a localized message per the backend contract:
///
/// - login 401: invalid email/password
/// - login 403: email not verified, or Google-only account
/// - reset 401: token expired / invalid / already used
/// - 422: validation error (e.g. password length)
class AuthFailure implements Exception {
  final int? statusCode;
  final String message;

  const AuthFailure({required this.message, this.statusCode});

  bool get isNetworkError => statusCode == null;

  bool get isGoogleOnlyAccount =>
      statusCode == 403 &&
      message.toLowerCase().contains('google sign-in');

  @override
  String toString() => message;
}
