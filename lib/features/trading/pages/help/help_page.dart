import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/help_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

/// Help desk — Midnight Signal cabinet surface.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  void _onCard(BuildContext context, HelpCardData card) {
    switch (card.id) {
      case 'earn':
        AppNavigator.pushNamed(context, AppRoutes.partner);
      case 'ai':
        AppNavigator.pushNamed(context, AppRoutes.aiAssistant);
      case 'temka':
        _toast(
          context,
          'Темки принимаются. Идеи оцениваем по ROI и уровню абсурда.',
        );
      case 'lost':
        _toast(
          context,
          'Держитесь. Рынок иногда шутит без чувства юмора.',
        );
      case 'won':
        _toast(
          context,
          'Поздравляем. Не забудьте про скромность — она дешевле маржи.',
        );
      case 'urgent':
        _toast(
          context,
          'Опишите ситуацию на support@bablo.community (когда он появится).',
        );
      default:
        _toast(context, card.title);
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

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
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          const _IntroCard(),
          const SizedBox(height: 22),
          const SectionLabel('Чем можем «помочь»'),
          const SizedBox(height: 12),
          for (final card in HelpConstants.cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HelpCard(
                data: card,
                onTap: () => _onCard(context, card),
              ),
            ),
          const SizedBox(height: 10),
          _SupportCta(
            onTap: () => AppNavigator.pushNamed(context, AppRoutes.partner),
          ),
          const SizedBox(height: 22),
          const _Footer(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primaryDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.primary.withValues(alpha: 0.45)),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: p.primaryHover,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HelpConstants.title,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      HelpConstants.subtitle,
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            HelpConstants.hook,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 13.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
      child: Text(
        HelpConstants.welcome,
        style: TextStyle(color: p.textPrimary, fontSize: 14.5, height: 1.45),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.data, required this.onTap});

  final HelpCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.primaryDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primary.withValues(alpha: 0.45)),
            ),
            child: Text(data.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.body,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.chevron_right_rounded,
              color: p.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCta extends StatelessWidget {
  const _SupportCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: p.primary,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                '${HelpConstants.ctaEmoji}  ${HelpConstants.ctaTitle}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          HelpConstants.ctaHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textMuted, fontSize: 12.5, height: 1.4),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: p.divider,
        ),
        const SizedBox(height: 16),
        Text(
          HelpConstants.dept,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          HelpConstants.motto,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textMuted,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
