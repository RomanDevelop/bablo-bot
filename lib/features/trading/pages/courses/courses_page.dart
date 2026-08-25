import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/courses_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

/// Courses hub — same Midnight Signal language as BABLO DAILY.
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

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
          Text(
            CoursesConstants.title,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CoursesConstants.subtitle,
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
            CoursesConstants.intro,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'МЕНТОРЫ',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          for (final mentor in CoursesConstants.mentors)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MentorCard(
                mentor: mentor,
                onTap: () => AppNavigator.pushNamed(context, mentor.route),
              ),
            ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  const _MentorCard({required this.mentor, required this.onTap});

  final CourseMentor mentor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: p.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'course-hero-${mentor.id}',
                child: Image.asset(
                  mentor.photoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: p.surfaceElevated,
                    child: Icon(
                      Icons.person_rounded,
                      color: p.primary,
                      size: 64,
                    ),
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
                    _RoleBadge(label: mentor.shortRole),
                    const Spacer(),
                    Text(
                      mentor.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${mentor.priceUsd}',
                      style: TextStyle(
                        color: p.primaryHover,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.primary.withValues(alpha: 0.55)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: p.primaryHover,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
