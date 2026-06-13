/// Token pair returned by login, Google login and refresh endpoints.
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'];
    final refreshToken = json['refresh_token'];

    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('auth response: missing access_token');
    }
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('auth response: missing refresh_token');
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: json['token_type'] is String
          ? json['token_type'] as String
          : 'bearer',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
      };
}
