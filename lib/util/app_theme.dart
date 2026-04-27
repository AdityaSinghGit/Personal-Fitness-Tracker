// Material 3 [ThemeData]: fitness orange, dark slate surfaces, and global snack bar defaults + touch-friendly buttons.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';

/// Dark fitness UI: primary CTA orange, volt-style secondary, floating snack bars that are never “plain white”.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.accentContainer,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.accentSecondary,
      onSecondary: AppColors.canvas,
      error: AppColors.error,
      onError: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    textTheme: _textTheme,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500, height: 1.35),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: null,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
      ),
    ),
  );

  return base.copyWith(
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      indicatorColor: AppColors.navSelectedIndicator,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(_textTheme.labelSmall),
      height: 72,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.4),
      indicatorColor: AppColors.navSelectedIndicator,
    ),
  );
}

TextTheme get _textTheme {
  return TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, height: 1.5),
    bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15, height: 1.45),
    bodySmall: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13, height: 1.4),
    labelSmall: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.inter(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );
}

/// Primary CTA — 48pt min height for mobile web (Apple HIG / Material touch).
ButtonStyle get primaryFancyButtonStyle => FilledButton.styleFrom(
  backgroundColor: AppColors.accent,
  foregroundColor: AppColors.onAccent,
  minimumSize: const Size(48, 50),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.2),
  elevation: 0,
  shadowColor: AppColors.accent.withValues(alpha: 0.4),
);

ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
  foregroundColor: AppColors.textPrimary,
  side: const BorderSide(color: AppColors.border),
  minimumSize: const Size(48, 48),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
);
