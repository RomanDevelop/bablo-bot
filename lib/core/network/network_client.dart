import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/data_error.dart';
import 'auth_interceptor.dart';

class NetworkClient {
  NetworkClient({String? apiEndpoint}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiEndpoint ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  void attachAuthInterceptor(AuthInterceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {AuthInterceptor.skipAuthKey: skipAuth}),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    bool skipAuth = false,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        options: Options(
          extra: {AuthInterceptor.skipAuthKey: skipAuth},
          receiveTimeout: receiveTimeout,
          responseType: ResponseType.json,
        ),
      );
      final raw = response.data;
      if (raw == null) {
        throw const DataError(
          errorCode: ErrorCode.unhandled,
          message: 'Пустой ответ сервера',
        );
      }
      if (raw is T) return raw;
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        return map as T;
      }
      return raw as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on DataError {
      rethrow;
    } catch (e) {
      throw DataError(
        errorCode: ErrorCode.unhandled,
        message: e.toString(),
      );
    }
  }

  Future<void> postVoid(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) async {
    try {
      await _dio.post<void>(
        path,
        data: data,
        options: Options(
          extra: {AuthInterceptor.skipAuthKey: skipAuth},
          validateStatus: (code) => code != null && code < 500,
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        options: Options(extra: {AuthInterceptor.skipAuthKey: skipAuth}),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  DataError _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);

    if (status == 401) {
      return DataError(
        errorCode: ErrorCode.unauthorized,
        message: detail ?? 'Unauthorized',
        data: _asMap(e.response?.data),
      );
    }
    if (status == 503) {
      return DataError(
        errorCode: ErrorCode.exchangeUnavailable,
        message: detail ?? 'Биржа недоступна',
        data: _asMap(e.response?.data),
      );
    }
    if (status == 400 || status == 402 || status == 404) {
      return DataError(
        errorCode: status == 404 ? ErrorCode.unhandled : ErrorCode.badRequest,
        message: detail ??
            (status == 402
                ? 'Недостаточно available RSV'
                : status == 404
                    ? 'Не найдено'
                    : 'Некорректный запрос'),
        data: _asMap(e.response?.data),
      );
    }
    if (status == 403) {
      return DataError(
        errorCode: ErrorCode.forbidden,
        message: detail ?? 'Недостаточно прав',
        data: _asMap(e.response?.data),
      );
    }
    if (status == 410) {
      return DataError(
        errorCode: ErrorCode.gone,
        message: detail ?? 'Функция больше недоступна',
        data: _asMap(e.response?.data),
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return DataError(
        errorCode: ErrorCode.network,
        message: detail ?? 'Нет соединения с сервером',
      );
    }
    return DataError(
      errorCode: ErrorCode.unhandled,
      message: detail ?? e.message ?? 'Неизвестная ошибка',
      data: _asMap(e.response?.data),
    );
  }

  String? _extractDetail(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is Map) {
        final msg = detail['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        final error = detail['error'];
        if (error is String && error.isNotEmpty) return error;
      }
      // FastAPI 422: detail is a list of {loc, msg, type}
      if (detail is List && detail.isNotEmpty) {
        final parts = <String>[];
        for (final item in detail.take(3)) {
          if (item is Map) {
            final msg = item['msg']?.toString();
            final loc = item['loc'];
            final field = loc is List && loc.isNotEmpty
                ? loc.last.toString()
                : null;
            if (msg != null && msg.isNotEmpty) {
              parts.add(field == null ? msg : '$field: $msg');
            }
          }
        }
        if (parts.isNotEmpty) return parts.join('; ');
      }
      if (detail != null) return detail.toString();
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
