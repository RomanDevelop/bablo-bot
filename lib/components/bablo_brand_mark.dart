import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import 'status_chip.dart';

/// AppBar brand mark — same height as status chips, teal accent.
class BabloBrandMark extends StatelessWidget {
  const BabloBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StatusChip.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: StatusChip.height,
            height: StatusChip.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StatusChip.radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.35),
                  AppColors.primaryDim,
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'B',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Bablo',
            style: GoogleFonts.dmSans(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
