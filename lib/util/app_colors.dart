// Warm dark “gym / performance” palette: energy orange, volt highlights, deep slate (fits Strava-adjacent fitness UIs).
import 'package:flutter/material.dart';

/// Semantic colors for a fitness product (training energy + readable dark surfaces).
class AppColors {
  AppColors._();

  // —— Base surfaces: blue-black, not flat grey (reads “dashboard / tracker”) ——
  static const Color canvas = Color(0xFF0A0B0F);
  static const Color surface = Color(0xFF12141A);
  static const Color surfaceElevated = Color(0xFF1A1D26);
  static const Color border = Color(0xFF2B303B);
  static const Color borderSubtle = Color(0xFF1C1F28);

  // —— Text ——
  static const Color textPrimary = Color(0xFFF1F2F4);
  static const Color textSecondary = Color(0xFFB0B5BE);
  static const Color textTertiary = Color(0xFF6E7582);

  // —— Brand: “training” orange (primary CTA) ——
  static const Color accent = Color(0xFFFF6B2C);
  static const Color accentDim = Color(0xFFEA580C);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentContainer = Color(0xFF3A1808);
  static const Color focusRing = Color(0x99FF6B2C);

  /// Selected tab pill on [NavigationBar] / [NavigationRail]: airy warm wash (not heavy [accentContainer]).
  static const Color navSelectedIndicator = Color(0x28FFB085);

  // —— Secondary energy: “volt / HR zone” (highlights, pills, data viz) ——
  static const Color accentSecondary = Color(0xFFCAE335);
  static const Color secondaryDim = Color(0xFF8BA312);
  static const Color secondaryContainer = Color(0xFF1E2410);
  static const Color accentAmberPill = Color(0xFFFEC654);
  static const Color pillBackground = Color(0xFF252018);

  // In-app toasts (never plain default white)
  static const Color snackSuccess = Color(0xFF0F2E1E);
  static const Color snackOnSuccess = Color(0xFFBBF7D0);
  static const Color snackError = Color(0xFF3F0E18);
  static const Color snackOnError = Color(0xFFFECDD3);
  static const Color snackInfo = Color(0xFF151E30);
  static const Color snackOnInfo = Color(0xFFBFDBFE);

  // States
  static const Color error = Color(0xFFFF7B8E);
  static const Color success = Color(0xFF34D399);
  static const Color successBright = Color(0xFF4ADE80);

  /// Subtle top-to-bottom read for the mesh background.
  static const List<Color> ambientGradient = <Color>[
    Color(0xFF1A0F0A),
    Color(0xFF0A0B0F),
    Color(0xFF070810),
  ];

  static const Color bentoWash = Color(0x12FFFFFF);

  /// Legacy names (bento tiles) — map to volt/secondary energy.
  static const Color accentLavender = accentSecondary;
  static const Color accentLavenderDim = secondaryContainer;
}
