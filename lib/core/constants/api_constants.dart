class ApiConstants {
  ApiConstants._();

  /// Production HTTPS API (AWS behind api.bablochatik.com).
  static const String _defaultBaseUrl = 'https://api.bablochatik.com/api/v1';

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl =>
      _envBaseUrl.isNotEmpty ? _envBaseUrl : _defaultBaseUrl;

  static const List<String> binanceIntervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
  ];
}
