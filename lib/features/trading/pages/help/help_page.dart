import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/help_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';

/// Black & gold Help desk — serious shell, sarcastic copy.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _bg = Color(0xFF070707);
  static const _card = Color(0xFF121212);
  static const _gold = Color(0xFFD4AF37);
  static const _goldSoft = Color(0xFFC9A227);
  static const _goldDim = Color(0x33D4AF37);
  static const _text = Color(0xFFF5F0E6);
  static const _muted = Color(0xFFA89F8E);

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
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _text),
        ),
        title: Text(
          'Help',
          style: GoogleFonts.dmSans(
            color: _text,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          const _IntroCard(),
          const SizedBox(height: 20),
          Text(
            'Чем можем «помочь»',
            style: GoogleFonts.playfairDisplay(
              color: _gold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1508),
            Color(0xFF0A0A0A),
            Color(0xFF14100A),
          ],
        ),
        border: Border.all(color: HelpPage._gold.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: HelpPage._goldDim,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HelpPage._goldDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HelpPage._gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: HelpPage._gold,
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
                      style: GoogleFonts.playfairDisplay(
                        color: HelpPage._gold,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      HelpConstants.subtitle,
                      style: GoogleFonts.dmSans(
                        color: HelpPage._text,
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
            style: GoogleFonts.dmSans(
              color: HelpPage._muted,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HelpPage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HelpPage._gold.withValues(alpha: 0.28)),
      ),
      child: Text(
        HelpConstants.welcome,
        style: GoogleFonts.dmSans(
          color: HelpPage._text,
          fontSize: 14.5,
          height: 1.45,
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            color: HelpPage._card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: HelpPage._gold.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HelpPage._goldDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HelpPage._gold.withValues(alpha: 0.35),
                  ),
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
                      style: GoogleFonts.dmSans(
                        color: HelpPage._text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.body,
                      style: GoogleFonts.dmSans(
                        color: HelpPage._muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: HelpPage._muted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCta extends StatelessWidget {
  const _SupportCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE0C35A),
                    Color(0xFFD4AF37),
                    Color(0xFFA67C00),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: HelpPage._gold.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${HelpConstants.ctaEmoji}  ${HelpConstants.ctaTitle}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF1A1200),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          HelpConstants.ctaHint,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: HelpPage._muted,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                HelpPage._gold.withValues(alpha: 0.55),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          HelpConstants.dept,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: HelpPage._goldSoft,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          HelpConstants.motto,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: HelpPage._muted,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
