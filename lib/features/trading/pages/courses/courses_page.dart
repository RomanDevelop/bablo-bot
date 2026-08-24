import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/courses_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/navigate_back.dart';

/// Courses hub — mentor list, expandable later.
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  static const _bg = Color(0xFF070707);
  static const _card = Color(0xFF121212);
  static const _gold = Color(0xFFD4AF37);
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
          'Courses',
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
          const SizedBox(height: 18),
          Text(
            CoursesConstants.intro,
            style: GoogleFonts.dmSans(
              color: _muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Менторы',
            style: GoogleFonts.playfairDisplay(
              color: _gold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final mentor in CoursesConstants.mentors)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MentorTile(
                mentor: mentor,
                onTap: () => AppNavigator.pushNamed(context, mentor.route),
              ),
            ),
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
        border: Border.all(color: CoursesPage._gold.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: CoursesPage._goldDim,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CoursesPage._goldDim,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CoursesPage._gold.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: CoursesPage._gold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CoursesConstants.title,
                  style: GoogleFonts.playfairDisplay(
                    color: CoursesPage._gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  CoursesConstants.subtitle,
                  style: GoogleFonts.dmSans(
                    color: CoursesPage._text,
                    fontSize: 13,
                    height: 1.35,
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

class _MentorTile extends StatelessWidget {
  const _MentorTile({required this.mentor, required this.onTap});

  final CourseMentor mentor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: CoursesPage._card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: CoursesPage._gold.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(17),
                ),
                child: Image.asset(
                  mentor.photoAsset,
                  width: 96,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96,
                    height: 112,
                    color: CoursesPage._card,
                    child: const Icon(
                      Icons.person_rounded,
                      color: CoursesPage._gold,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: GoogleFonts.playfairDisplay(
                          color: CoursesPage._text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor.shortRole,
                        style: GoogleFonts.dmSans(
                          color: CoursesPage._muted,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${mentor.priceUsd}',
                        style: GoogleFonts.dmSans(
                          color: CoursesPage._gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: CoursesPage._muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
