import 'package:flutter/material.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/partner_constants.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'di/partner_wm_builder.dart';
import 'partner_wm.dart';

class PartnerPage extends CoreMwwmWidget<PartnerWidgetModel> {
  PartnerPage({super.key})
      : super(widgetModelBuilder: createPartnerWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.partner),
        builder: (_) => PartnerPage(),
      );

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState
    extends MwwmWidgetState<PartnerPage, PartnerWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PartnerState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const PartnerState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            wm.clearMessage();
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Партнёрство')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _MonobankJarCard(
                hasValidUrl: wm.hasJarUrl,
                onOpen: wm.openMonobankJar,
              ),
              const SizedBox(height: 16),
              _CryptoWalletsCard(
                wallets: wm.wallets,
                onCopy: wm.copyWalletAddress,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonobankJarCard extends StatelessWidget {
  const _MonobankJarCard({
    required this.hasValidUrl,
    required this.onOpen,
  });

  final bool hasValidUrl;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Image.asset(
            PartnerConstants.jarQrAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              height: 280,
              color: AppColors.surfaceElevated,
              alignment: Alignment.center,
              child: Text(
                'QR не найден в assets',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
          if (hasValidUrl)
            Container(
              width: double.infinity,
              color: const Color(0xFF3B0A7A),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B0A7A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onOpen,
                child: const Text(
                  'Открыть банку в Monobank',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CryptoWalletsCard extends StatelessWidget {
  const _CryptoWalletsCard({
    required this.wallets,
    required this.onCopy,
  });

  final List<CryptoWallet> wallets;
  final ValueChanged<CryptoWallet> onCopy;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Крипто-кошелёк'),
          const SizedBox(height: 8),
          Text(
            'USDT-перевод на кошелёк бота. Сеть проверяйте внимательно.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (wallets.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Адреса кошельков не настроены.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            )
          else
            ...wallets.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WalletRow(wallet: w, onCopy: () => onCopy(w)),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.wallet, required this.onCopy});

  final CryptoWallet wallet;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.network,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  wallet.address,
                  style: context.tradingText.monoSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            tooltip: 'Копировать',
            icon: Icon(Icons.copy, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
