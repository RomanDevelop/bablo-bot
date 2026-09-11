enum ErrorCode {
  network,
  exchangeUnavailable,
  badRequest,
  unauthorized,
  forbidden,
  gone,
  unhandled,
}

class DataError implements Exception {
  const DataError({
    required this.errorCode,
    this.message,
    this.data,
  });

  final ErrorCode errorCode;
  final String? message;
  final Map<String, dynamic>? data;

  /// Backend `detail.error` (e.g. `plan_required`, `min_stake`).
  String? get apiError {
    final detail = data?['detail'];
    if (detail is Map) {
      final error = detail['error'];
      if (error != null && error.toString().isNotEmpty) return error.toString();
    }
    final error = data?['error'];
    if (error != null && error.toString().isNotEmpty) return error.toString();
    return null;
  }

  String get displayMessage {
    if (message != null && message!.isNotEmpty) return message!;
    switch (errorCode) {
      case ErrorCode.network:
        return 'Нет соединения с сервером';
      case ErrorCode.exchangeUnavailable:
        return 'Биржа недоступна';
      case ErrorCode.badRequest:
        return 'Некорректный запрос';
      case ErrorCode.unauthorized:
        return 'Требуется вход';
      case ErrorCode.forbidden:
        return 'Недостаточно прав';
      case ErrorCode.gone:
        return 'Функция больше недоступна';
      case ErrorCode.unhandled:
        return 'Неизвестная ошибка';
    }
  }

  @override
  String toString() => 'DataError($errorCode): $displayMessage';
}
