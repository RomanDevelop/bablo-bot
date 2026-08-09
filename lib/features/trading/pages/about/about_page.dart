import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/about_constants.dart';
import '../../../../core/navigation/navigate_back.dart';

/// Black & gold Bablo Community About — brand surface, not trading logic.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _bg = Color(0xFF070707);
  static const _card = Color(0xFF121212);
  static const _gold = Color(0xFFD4AF37);
  static const _goldSoft = Color(0xFFC9A227);
  static const _goldDim = Color(0x33D4AF37);
  static const _text = Color(0xFFF5F0E6);
  static const _muted = Color(0xFFA89F8E);

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
          'About',
          style: GoogleFonts.dmSans(
            color: _text,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Hero(),
          SizedBox(height: 22),
          _IntroCard(),
          SizedBox(height: 16),
          _PrincipleCard(),
          SizedBox(height: 22),
          _SectionTitle('Основные направления'),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        color: AboutPage._gold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AboutPage._gold.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AboutConstants.heroAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AboutPage._card,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AboutPage._gold,
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
                      Color(0x00000000),
                      Color(0xCC070707),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AboutConstants.brand,
                      style: GoogleFonts.playfairDisplay(
                        color: AboutPage._gold,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AboutConstants.tagline,
                      style: GoogleFonts.dmSans(
                        color: AboutPage._text,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldCard extends StatelessWidget {
  const _GoldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AboutPage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AboutPage._gold.withValues(alpha: 0.28)),
      ),
      child: child,
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return _GoldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.intro,
            style: GoogleFonts.dmSans(
              color: AboutPage._text,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AboutConstants.mission,
            style: GoogleFonts.dmSans(
              color: AboutPage._muted,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1508),
            Color(0xFF0E0E0E),
            Color(0xFF1A1206),
          ],
        ),
        border: Border.all(color: AboutPage._goldSoft, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AboutPage._goldDim,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.principleTitle.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: AboutPage._goldSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AboutConstants.principle,
            style: GoogleFonts.playfairDisplay(
              color: AboutPage._gold,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AboutPage._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AboutPage._gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AboutPage._goldDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AboutPage._gold.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: AboutPage._gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: AboutPage._text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: AboutPage._muted,
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
    return _GoldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city_rounded, color: AboutPage._gold),
              const SizedBox(width: 8),
              Text(
                AboutConstants.headOfficeTitle,
                style: GoogleFonts.playfairDisplay(
                  color: AboutPage._gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                style: GoogleFonts.dmSans(
                  color: AboutPage._text,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1008),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AboutPage._gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AboutConstants.disclaimerTitle.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: AboutPage._gold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AboutConstants.disclaimer,
            style: GoogleFonts.dmSans(
              color: AboutPage._muted,
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
