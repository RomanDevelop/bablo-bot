import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/auth/models/auth_tokens.dart';
import '../auth/token_storage.dart';

/// Adds Bearer token and refreshes on 401 (token rotation).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    required Future<AuthTokens?> Function() onRefresh,
    required void Function() onSessionExpired,
  })  : _tokens = tokenStorage,
        _dio = dio,
        _onRefresh = onRefresh,
        _onSessionExpired = onSessionExpired;

  final TokenStorage _tokens;
  final Dio _dio;
  final Future<AuthTokens?> Function() _onRefresh;
  final void Function() _onSessionExpired;

  Completer<AuthTokens?>? _refreshCompleter;

  static const skipAuthKey = 'skipAuth';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['dio'] = _dio;
    final skipAuth = options.extra[skipAuthKey] == true;
    final path = options.path;
    if (!skipAuth && !path.startsWith('/auth/')) {
      final access = _tokens.readTokens()?.accessToken;
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final path = err.requestOptions.path;
    final skipAuth = err.requestOptions.extra[skipAuthKey] == true;

    if (response?.statusCode != 401 ||
        skipAuth ||
        path.startsWith('/auth/')) {
      handler.next(err);
      return;
    }

    try {
      final tokens = await _refreshOnce();
      if (tokens == null) {
        _onSessionExpired();
        handler.next(err);
        return;
      }

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final clone = await _dio.fetch<dynamic>(opts);
      handler.resolve(clone);
    } catch (_) {
      _onSessionExpired();
      handler.next(err);
    }
  }

  Future<AuthTokens?> _refreshOnce() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<AuthTokens?>();
    try {
      final tokens = await _onRefresh();
      _refreshCompleter!.complete(tokens);
      return tokens;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
