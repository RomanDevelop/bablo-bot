/// Non-web stub — Telegram Mini App SDK unavailable.
class TelegramWebAppBridge {
  const TelegramWebAppBridge();

  bool get isAvailable => false;

  String? get initData => null;

  void ready() {}

  void expand() {}
}

TelegramWebAppBridge get telegramWebApp => const TelegramWebAppBridge();
