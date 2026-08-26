import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../components/navigation/right_side_menu.dart';
import '../../../../components/navigation/side_menu_button.dart';
import '../../../../components/premium_service_dialog.dart';
import '../../../../core/constants/external_services_config.dart';
import '../../../../core/constants/market_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_controller.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        title: Text(
          'Рынок',
          style: TextStyle(
            color: p.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SideMenuButton(onPressed: onOpenMenu ?? () {}),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
        children: [
          _MarketLinkCard(
            palette: p,
            icon: Icons.candlestick_chart_rounded,
            iconColor: p.primary,
            title: 'Chart · Crypto Futures',
            subtitle: 'Alligator H1 · сигналы и свечи бота',
            onTap: () => AppNavigator.pushNamed(context, AppRoutes.chart),
          ),
          const SizedBox(height: 12),
          _MarketLinkCard(
            palette: p,
            icon: Icons.ssid_chart_rounded,
            iconColor: p.buy,
            title: MarketConstants.usStocksTitle,
            subtitle: MarketConstants.usStocksSubtitle,
            onTap: () => AppNavigator.pushNamed(context, AppRoutes.usStocks),
          ),
          const SizedBox(height: 12),
          _MarketLinkCard(
            palette: p,
            icon: Icons.account_balance_wallet_rounded,
            iconColor: p.hold,
            title: 'Portfolio',
            subtitle: 'Позиция бота и futures wallet',
            onTap: () => AppNavigator.pushNamed(context, AppRoutes.portfolio),
          ),
          const SizedBox(height: 20),
          const SectionLabel('Сервисы'),
          const SizedBox(height: 10),
          ...ExternalServicesConfig.leisure.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExternalServiceMenuItem(
                palette: p,
                link: link,
                onTap: () {
                  if (link.isInternal) {
                    AppNavigator.pushNamed(context, link.internalRoute!);
                    return;
                  }
                  if (link.requiresPremium) {
                    showPremiumServiceDialog(context, link);
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        link.hasUrl
                            ? 'Открой «${link.title}» из бокового меню'
                            : '${link.title}: ссылка скоро появится',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketLinkCard extends StatelessWidget {
  const _MarketLinkCard({
    required this.palette,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppPalette palette;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.textMuted),
        ],
      ),
    );
  }
}
