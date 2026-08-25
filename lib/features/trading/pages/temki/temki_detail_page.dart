import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/temki_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../daily/widgets/daily_network_image.dart';

class TemkiDetailPage extends StatelessWidget {
  const TemkiDetailPage({super.key, required this.item});

  final TemkiListing item;

  Future<void> _deal(BuildContext context) async {
    final uri = TemkiConstants.dealUri(item.title);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Открой Telegram: @${TemkiConstants.telegramHandle}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Scaffold(
      backgroundColor: p.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Темки, мутки'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(item: item),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: p.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      item.place.toUpperCase(),
                      style: TextStyle(
                        color: p.primaryHover,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.bio,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                const SectionLabel('Что входит'),
                const SizedBox(height: 12),
                for (final perk in item.perks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TradingCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(perk.$1, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              perk.$2,
                              style: TextStyle(
                                color: p.textPrimary,
                                fontSize: 13.5,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                TradingCard(
                  borderColor: p.primary.withValues(alpha: 0.45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BABLO VERDICT',
                        style: TextStyle(
                          color: p.primaryHover,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.quote,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                TradingCard(
                  borderColor: p.primary.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.kind == TemkiKind.plot ? 'СТОИМОСТЬ' : 'АРЕНДА',
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.priceUsd}',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'за ${item.unit}',
                        style: TextStyle(
                          color: p.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatRsv(item.rsvAmount)} ${TemkiConstants.rsvTicker}',
                        style: TextStyle(
                          color: p.primaryHover,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reserve · 1 RSV = \$${TemkiConstants.rsvUsd}',
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: p.primary,
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                  child: InkWell(
                    onTap: () => _deal(context),
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: p.onPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.ctaLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: p.onPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TemkiConstants.exchangeNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      AppNavigator.pushNamed(context, AppRoutes.exchange),
                  child: Text(
                    'Currency Exchange →',
                    style: TextStyle(
                      color: p.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TemkiConstants.disclaimer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Сделка: @${TemkiConstants.telegramHandle}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Фото: ${item.imageCredit}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatRsv(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final left = s.length - i;
      if (i != 0 && left % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.item});

  final TemkiListing item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: TemkiConstants.heroTag(item.id),
          child: DailyNetworkImage(
            url: item.imageUrl,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            expand: false,
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000814),
                    Color(0x00000814),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
