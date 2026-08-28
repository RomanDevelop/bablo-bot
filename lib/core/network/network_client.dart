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
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        options: Options(extra: {AuthInterceptor.skipAuthKey: skipAuth}),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
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
    if (status == 400) {
      return DataError(
        errorCode: ErrorCode.badRequest,
        message: detail ?? 'Некорректный запрос',
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
        if (msg is String) return msg;
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
