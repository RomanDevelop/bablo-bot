class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.sessionId,
    this.tokenType = 'bearer',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final String sessionId;
  final String tokenType;

  bool get isAccessExpired => DateTime.now().isAfter(accessExpiresAt);

  bool get shouldRefreshProactively {
    final refreshAt = accessExpiresAt.subtract(const Duration(minutes: 2));
    return DateTime.now().isAfter(refreshAt);
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessExpiresAt: DateTime.parse(json['access_expires_at'] as String),
      sessionId: json['session_id'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'access_expires_at': accessExpiresAt.toIso8601String(),
        'session_id': sessionId,
        'token_type': tokenType,
      };
}

class AuthTelegramResponse {
  const AuthTelegramResponse({
    required this.tokens,
    required this.bootstrap,
  });

  final AuthTokens tokens;
  final Map<String, dynamic> bootstrap;

  factory AuthTelegramResponse.fromJson(Map<String, dynamic> json) {
    return AuthTelegramResponse(
      tokens: AuthTokens.fromJson(json),
      bootstrap: Map<String, dynamic>.from(
        json['bootstrap'] as Map? ?? const {},
      ),
    );
  }
}
