import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/courses_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';

/// Shared mentor course page — black & gold profile + program + price.
class MentorCoursePage extends StatelessWidget {
  const MentorCoursePage({super.key, required this.content});

  final MentorCourseContent content;

  static const _bg = Color(0xFF070707);
  static const _card = Color(0xFF121212);
  static const _gold = Color(0xFFD4AF37);
  static const _goldSoft = Color(0xFFC9A227);
  static const _goldDim = Color(0x33D4AF37);
  static const _text = Color(0xFFF5F0E6);
  static const _muted = Color(0xFFA89F8E);

  void _enroll(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Запись на курс ${content.name} — скоро. '
          'Пока можно поддержать через Partner.',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Partner',
          onPressed: () => AppNavigator.pushNamed(context, AppRoutes.partner),
        ),
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
          content.name,
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
          _Hero(content: content),
          const SizedBox(height: 18),
          _BioCard(content: content),
          const SizedBox(height: 22),
          Text(
            'Программа',
            style: GoogleFonts.playfairDisplay(
              color: _gold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in content.program)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProgramTile(emoji: item.$1, text: item.$2),
            ),
          const SizedBox(height: 8),
          _FormatCard(content: content),
          const SizedBox(height: 18),
          _QuoteCard(content: content),
          const SizedBox(height: 22),
          _PriceBlock(content: content),
          const SizedBox(height: 16),
          _EnrollButton(onTap: () => _enroll(context)),
          const SizedBox(height: 20),
          _Signature(content: content),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: MentorCoursePage._gold.withValues(alpha: 0.45),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                content.photoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: MentorCoursePage._card,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    color: MentorCoursePage._gold,
                    size: 72,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.45, 0.72, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.name,
                      style: GoogleFonts.playfairDisplay(
                        color: MentorCoursePage._gold,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content.role,
                      style: GoogleFonts.dmSans(
                        color: MentorCoursePage._text,
                        fontSize: 13.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
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

class _BioCard extends StatelessWidget {
  const _BioCard({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MentorCoursePage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: MentorCoursePage._gold.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        content.bio,
        style: GoogleFonts.dmSans(
          color: MentorCoursePage._text,
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: MentorCoursePage._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MentorCoursePage._gold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                color: MentorCoursePage._text,
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1508),
            Color(0xFF0E0E0E),
          ],
        ),
        border: Border.all(color: MentorCoursePage._goldSoft, width: 1),
      ),
      child: Text(
        content.format,
        style: GoogleFonts.dmSans(
          color: MentorCoursePage._muted,
          fontSize: 13.5,
          height: 1.4,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: MentorCoursePage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: MentorCoursePage._gold.withValues(alpha: 0.4),
        ),
        boxShadow: const [
          BoxShadow(
            color: MentorCoursePage._goldDim,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        content.quote,
        style: GoogleFonts.playfairDisplay(
          color: MentorCoursePage._gold,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.4,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1808),
            Color(0xFF12100A),
            Color(0xFF1A1406),
          ],
        ),
        border: Border.all(color: MentorCoursePage._gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: MentorCoursePage._gold.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'СТОИМОСТЬ',
            style: GoogleFonts.dmSans(
              color: MentorCoursePage._goldSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${content.priceUsd}',
            style: GoogleFonts.playfairDisplay(
              color: MentorCoursePage._gold,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content.priceSubtitle,
            style: GoogleFonts.dmSans(
              color: MentorCoursePage._muted,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrollButton extends StatelessWidget {
  const _EnrollButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
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
                color: MentorCoursePage._gold.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'ЗАПИСАТЬСЯ НА КУРС',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: const Color(0xFF1A1200),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Signature extends StatelessWidget {
  const _Signature({required this.content});

  final MentorCourseContent content;

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
                MentorCoursePage._gold.withValues(alpha: 0.55),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content.signature,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: MentorCoursePage._goldSoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
