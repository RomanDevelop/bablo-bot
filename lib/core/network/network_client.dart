import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/data_error.dart';

class NetworkClient {
  NetworkClient({String? apiEndpoint}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiEndpoint ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
  }) async {
    try {
      final response = await _dio.post<T>(path, data: data);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
  }) async {
    try {
      final response = await _dio.patch<T>(path, data: data);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  DataError _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);

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
