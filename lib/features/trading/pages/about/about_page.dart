import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/about_constants.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

/// About — Midnight Signal cabinet surface.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Hero(),
          SizedBox(height: 16),
          _IntroCard(),
          SizedBox(height: 16),
          _PrincipleCard(),
          SizedBox(height: 22),
          SectionLabel('Основные направления'),
          SizedBox(height: 12),
          _DirectionsList(),
          SizedBox(height: 14),
          _OfficeCard(),
          SizedBox(height: 16),
          _DisclaimerCard(),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AboutConstants.heroAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: p.surfaceElevated,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: p.primary,
                  size: 64,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000814),
                    Color(0x00000814),
                    Color(0xE6000814),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0B1220),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      'ABOUT',
                      style: TextStyle(
                        color: p.primaryHover,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AboutConstants.brand,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AboutConstants.tagline,
                    style: TextStyle(
                      color: p.primaryHover,
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.intro,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AboutConstants.mission,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  const _PrincipleCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.principleTitle.toUpperCase(),
            style: TextStyle(
              color: p.primaryHover,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AboutConstants.principle,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsList extends StatelessWidget {
  const _DirectionsList();

  static const _icons = <IconData>[
    Icons.auto_awesome_outlined,
    Icons.show_chart_rounded,
    Icons.account_balance_outlined,
    Icons.analytics_outlined,
    Icons.science_outlined,
    Icons.handshake_outlined,
    Icons.nightlife_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < AboutConstants.directions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DirectionTile(
              title: AboutConstants.directions[i].$1,
              subtitle: AboutConstants.directions[i].$2,
              icon: _icons[i % _icons.length],
            ),
          ),
      ],
    );
  }
}

class _DirectionTile extends StatelessWidget {
  const _DirectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.primaryDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primary.withValues(alpha: 0.45)),
            ),
            child: Icon(icon, color: p.primaryHover, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  const _OfficeCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city_rounded, color: p.primary),
              const SizedBox(width: 8),
              Text(
                AboutConstants.headOfficeTitle,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in AboutConstants.headOfficeLines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.disclaimerTitle.toUpperCase(),
            style: TextStyle(
              color: p.primaryHover,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AboutConstants.disclaimer,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
