/// Partner / support payment endpoints.
class PartnerConstants {
  PartnerConstants._();

  /// Optional deep-link for «Открыть банку». Visual QR is [jarQrAsset].
  static const monobankJarUrl = String.fromEnvironment(
    'MONOBANK_JAR_URL',
    defaultValue: '',
  );

  static const jarQrAsset = 'assets/partner/monobank_jar_qr.png';

  /// USDT on EVM chains (ERC-20 / BEP-20).
  static const usdtEvmAddress =
      '0x324EB0E51465d70c3D546BeE1cf18F74A01E9924';

  static const usdtEvmNetwork = 'USDT · ERC-20 / BEP-20';

  static const List<CryptoWallet> cryptoWallets = [
    CryptoWallet(
      network: usdtEvmNetwork,
      address: usdtEvmAddress,
    ),
  ];
}

class CryptoWallet {
  const CryptoWallet({
    required this.network,
    required this.address,
  });

  final String network;
  final String address;
}
