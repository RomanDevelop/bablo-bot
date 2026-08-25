import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/temki_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/theme_controller.dart';
import 'widgets/temki_carousel.dart';

class TemkiPage extends StatelessWidget {
  const TemkiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Темки, мутки'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          Text(
            TemkiConstants.title,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TemkiConstants.subtitle,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            TemkiConstants.intro,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TradingCard(
            borderColor: p.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TemkiConstants.payNote,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  TemkiConstants.exchangeNote,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () =>
                      AppNavigator.pushNamed(context, AppRoutes.exchange),
                  icon: Icon(Icons.currency_exchange_rounded, color: p.primary),
                  label: Text(
                    'Currency Exchange',
                    style: TextStyle(
                      color: p.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TemkiCarousel(
            label: TemkiConstants.plotsLabel,
            items: TemkiCatalog.plots,
          ),
          const SizedBox(height: 22),
          TemkiCarousel(
            label: TemkiConstants.shipsLabel,
            items: TemkiCatalog.ships,
          ),
        ],
      ),
    );
  }
}
