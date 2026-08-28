import 'dart:js_interop';

@JS('Telegram')
external Telegram? get _telegram;

extension type Telegram._(JSObject _) implements JSObject {
  external TelegramWebApp get WebApp;
}

extension type TelegramWebApp._(JSObject _) implements JSObject {
  external String get initData;
  external void ready();
  external void expand();
}

/// Reads Telegram Mini App SDK on Flutter Web.
class TelegramWebAppBridge {
  const TelegramWebAppBridge();

  TelegramWebApp? get _app => _telegram?.WebApp;

  bool get isAvailable => _app != null;

  String? get initData {
    final data = _app?.initData ?? '';
    return data.isNotEmpty ? data : null;
  }

  void ready() => _app?.ready();

  void expand() => _app?.expand();
}

TelegramWebAppBridge get telegramWebApp => const TelegramWebAppBridge();
