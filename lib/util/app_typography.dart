// Display and marketing text styles (hero, eyebrow) layered on the base [TextTheme] from [app_theme].

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';

/// Extra-large hero lines for marketing surfaces (not registered on [ThemeData] to avoid over-scoping).
class AppTypography {
  AppTypography._();

  /// Main landing / dashboard hero — tight line height, slight negative tracking.
  static TextStyle heroHeadline(double width) {
    final double size = width >= 900 ? 48 : 32;
    return GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.8,
    );
  }

  static TextStyle heroSubline(BuildContext context) {
    return GoogleFonts.inter(
      color: AppColors.textSecondary,
      fontSize: 18,
      height: 1.5,
    );
  }

  /// Small caps–style section label.
  static TextStyle eyebrow() {
    return GoogleFonts.inter(
      color: AppColors.accentSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
    );
  }
}
