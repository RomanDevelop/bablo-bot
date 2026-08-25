import 'package:flutter/material.dart';

import '../../../../../core/constants/courses_constants.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import 'course_mentor_photo.dart';

/// Courses hub carousel — same PageView language as BABLO DAILY, square cards.
class CoursesCarousel extends StatefulWidget {
  const CoursesCarousel({super.key});

  @override
  State<CoursesCarousel> createState() => _CoursesCarouselState();
}

class _CoursesCarouselState extends State<CoursesCarousel> {
  late final PageController _pageController;
  int _page = 0;

  static const _fraction = 0.86;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _fraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _open(CourseMentor mentor) {
    context.push(
      AppRoutes.courseMentor(mentor.id),
      extra: MentorCourses.byId(mentor.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mentors = CoursesConstants.mentors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'МЕНТОРЫ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = constraints.maxWidth * _fraction - 10;
            return Column(
              children: [
                SizedBox(
                  height: cardSize,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    itemCount: mentors.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, index) {
                      final mentor = mentors[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _MentorCard(
                          mentor: mentor,
                          onTap: () => _open(mentor),
                        ),
                      );
                    },
                  ),
                ),
                if (mentors.length > 1) ...[
                  const SizedBox(height: 10),
                  _Dots(count: mentors.length, index: _page),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MentorCard extends StatelessWidget {
  const _MentorCard({required this.mentor, required this.onTap});

  final CourseMentor mentor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CourseMentorPhoto(
              asset: mentor.photoAsset,
              heroTag: CoursesConstants.heroTag(mentor.id),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${mentor.priceUsd}',
                    style: TextStyle(
                      color: AppColors.primaryHover,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryHover,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
