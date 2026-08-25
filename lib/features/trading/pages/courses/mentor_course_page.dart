import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/courses_constants.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

/// Mentor detail — Daily article layout, enroll via Telegram DM.
class MentorCoursePage extends StatelessWidget {
  const MentorCoursePage({super.key, required this.content});

  final MentorCourseContent content;

  Future<void> _enroll(BuildContext context) async {
    final uri = CoursesConstants.enrollUri(content.name);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Открой Telegram: @${CoursesConstants.telegramHandle}'),
        ),
      );
    }
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
        title: const Text('Courses'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          _HeroImage(content: content),
          const SizedBox(height: 16),
          _RoleBadge(label: content.role),
          const SizedBox(height: 10),
          Text(
            content.name,
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
            content.bio,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Программа'),
          const SizedBox(height: 12),
          for (final item in content.program)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProgramTile(emoji: item.$1, text: item.$2),
            ),
          const SizedBox(height: 8),
          TradingCard(
            borderColor: p.primary.withValues(alpha: 0.35),
            child: Text(
              content.format,
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 13.5,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _QuoteCard(text: content.quote),
          const SizedBox(height: 22),
          _PriceBlock(content: content),
          const SizedBox(height: 16),
          _EnrollButton(onTap: () => _enroll(context)),
          const SizedBox(height: 20),
          Text(
            content.signature,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Запись: @${CoursesConstants.telegramHandle}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Hero(
          tag: 'course-hero-${content.id}',
          child: Image.asset(
            content.photoAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: p.surfaceElevated,
              child: Icon(Icons.person_rounded, color: p.primary, size: 72),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: p.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.primary.withValues(alpha: 0.45)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: p.primaryHover,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
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
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
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
            text,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.content});

  final MentorCourseContent content;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      child: Column(
        children: [
          Text(
            'СТОИМОСТЬ',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${content.priceUsd}',
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
            content.priceSubtitle,
            style: TextStyle(color: p.textSecondary, fontSize: 12.5),
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
    final p = context.watch<ThemeController>().palette;
    return Material(
      color: p.primary,
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, color: p.onPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                CoursesConstants.enrollButtonLabel,
                style: TextStyle(
                  color: p.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
