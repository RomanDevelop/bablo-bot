/// Partner / support payment endpoints.
///
/// Override at build time:
/// `--dart-define=MONOBANK_JAR_URL=https://send.monobank.ua/jar/...`
/// `--dart-define=CRYPTO_USDT_TRC20=T...`
class PartnerConstants {
  PartnerConstants._();

  /// Optional deep-link for «Открыть банку». Visual QR is [jarQrAsset].
  static const monobankJarUrl = String.fromEnvironment(
    'MONOBANK_JAR_URL',
    defaultValue: '',
  );

  static const jarQrAsset = 'assets/partner/monobank_jar_qr.png';

  static const usdtTrc20Address = String.fromEnvironment(
    'CRYPTO_USDT_TRC20',
    defaultValue: '',
  );

  static const usdtTonAddress = String.fromEnvironment(
    'CRYPTO_USDT_TON',
    defaultValue: '',
  );

  static const List<CryptoWallet> cryptoWallets = [
    CryptoWallet(
      network: 'USDT · TRC20',
      addressEnvKey: 'CRYPTO_USDT_TRC20',
      address: usdtTrc20Address,
    ),
    CryptoWallet(
      network: 'USDT · TON',
      addressEnvKey: 'CRYPTO_USDT_TON',
      address: usdtTonAddress,
    ),
  ];

  static List<CryptoWallet> get configuredWallets =>
      cryptoWallets.where((w) => w.address.isNotEmpty).toList(growable: false);
}

class CryptoWallet {
  const CryptoWallet({
    required this.network,
    required this.address,
    required this.addressEnvKey,
  });

  final String network;
  final String address;
  final String addressEnvKey;
}
