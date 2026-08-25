import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Mentor portrait. Carousel uses [expand] + cover crop; detail shows the full photo.
class CourseMentorPhoto extends StatelessWidget {
  const CourseMentorPhoto({
    super.key,
    required this.asset,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.alignment = const Alignment(0, -0.18),
    this.expand = true,
  });

  final String asset;
  final String? heroTag;
  final BoxFit fit;
  final Alignment alignment;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: expand ? double.infinity : null,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: AppColors.surfaceElevated,
        child: SizedBox(
          height: expand ? double.infinity : 220,
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 64),
        ),
      ),
    );
    if (heroTag == null) return image;
    return Hero(tag: heroTag!, child: image);
  }
}
