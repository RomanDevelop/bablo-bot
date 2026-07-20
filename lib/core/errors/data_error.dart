enum ErrorCode {
  network,
  exchangeUnavailable,
  badRequest,
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

  String get displayMessage {
    if (message != null && message!.isNotEmpty) return message!;
    switch (errorCode) {
      case ErrorCode.network:
        return 'Нет соединения с сервером';
      case ErrorCode.exchangeUnavailable:
        return 'Биржа недоступна';
      case ErrorCode.badRequest:
        return 'Некорректный запрос';
      case ErrorCode.gone:
        return 'Функция больше недоступна';
      case ErrorCode.unhandled:
        return 'Неизвестная ошибка';
    }
  }

  @override
  String toString() => 'DataError($errorCode): $displayMessage';
}
