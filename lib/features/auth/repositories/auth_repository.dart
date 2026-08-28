import 'package:dio/dio.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/data_error.dart';
import '../../../core/network/network_client.dart';
import '../../../core/telegram/telegram_web_app.dart';
import '../models/auth_tokens.dart';
import '../models/bablo_bootstrap.dart';

class AuthRepository {
  AuthRepository({
    required NetworkClient networkClient,
    required TokenStorage tokenStorage,
  })  : _client = networkClient,
        _tokens = tokenStorage,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

  final NetworkClient _client;
  final TokenStorage _tokens;
  final Dio _refreshDio;

  AuthTokens? get currentTokens => _tokens.readTokens();

  Future<AuthTelegramResponse> loginWithTelegram({
    required String initData,
    String? deviceName,
    String platform = 'web',
    String appVersion = '1.0.0',
  }) async {
    final body = {
      'init_data': initData,
      'device_name': deviceName ?? _defaultDeviceName(),
      'platform': platform,
      'app_version': appVersion,
    };
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/telegram',
      data: body,
      skipAuth: true,
    );
    final response = AuthTelegramResponse.fromJson(data);
    await _persistSession(response.tokens, response.bootstrap);
    return response;
  }

  Future<AuthTokens> refreshTokens() async {
    final current = _tokens.readTokens();
    if (current == null) {
      throw const DataError(
        errorCode: ErrorCode.unauthorized,
        message: 'No refresh token',
      );
    }
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': current.refreshToken},
      );
      final tokens = AuthTokens.fromJson(response.data ?? const {});
      await _tokens.saveTokens(tokens);
      return tokens;
    } on DioException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> logout() async {
    final current = _tokens.readTokens();
    if (current != null) {
      try {
        await _client.postVoid(
          '/auth/logout',
          data: {'refresh_token': current.refreshToken},
          skipAuth: true,
        );
      } catch (_) {
        // Best-effort server logout.
      }
    }
    await _tokens.clearAll();
  }

  Future<BabloBootstrap> fetchBootstrap() async {
    final data = await _client.get<Map<String, dynamic>>('/users/me');
    final bootstrap = BabloBootstrap.fromJson(data);
    await _tokens.saveBootstrap(bootstrap);
    return bootstrap;
  }

  Future<void> _persistSession(
    AuthTokens tokens,
    Map<String, dynamic> bootstrapJson,
  ) async {
    await _tokens.saveTokens(tokens);
    if (bootstrapJson.isNotEmpty) {
      await _tokens.saveBootstrap(BabloBootstrap.fromJson(bootstrapJson));
    }
  }

  String? readTelegramInitData() {
    telegramWebApp.ready();
    telegramWebApp.expand();
    return telegramWebApp.initData;
  }

  String _defaultDeviceName() {
    return 'Flutter Web Mini App';
  }

  DataError _mapAuthError(DioException e) {
    final status = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);
    if (status == 401) {
      return DataError(
        errorCode: ErrorCode.unauthorized,
        message: detail ?? 'Session expired',
      );
    }
    if (status == 400) {
      return DataError(
        errorCode: ErrorCode.badRequest,
        message: detail ?? 'Invalid login',
      );
    }
    return DataError(
      errorCode: ErrorCode.network,
      message: detail ?? e.message ?? 'Auth request failed',
    );
  }

  String? _extractDetail(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is Map) {
        final msg = detail['message'];
        if (msg is String) return msg;
      }
    }
    return null;
  }
}
