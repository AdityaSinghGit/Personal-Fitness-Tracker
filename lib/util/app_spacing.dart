// Consistent spacing, radii, and elevation tokens for a calm, grid-aligned layout on web and mobile browser.

import 'package:flutter/material.dart';

/// Spacing, corner radii, and animation durations.
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s64 = 64;
  static const double maxContentWidth = 1200;
  static const double maxContentWide = 1280;
  /// When wider than this, the auth page uses a two-column marketing + form layout.
  static const double authTwoColumnAt = 1000;
  static const double railBreakpoint = 900;
  static const double bentoMinTile = 200;
  static const double cardRadius = 20;
  static const double fieldRadius = 12;
  static const Duration pageFade = Duration(milliseconds: 280);
  static const Duration stagger = Duration(milliseconds: 40);
}

/// Standard horizontal padding for views when wide.
EdgeInsets viewPaddingForWidth(double w) {
  if (w >= 900) {
    return const EdgeInsets.symmetric(horizontal: AppSpacing.s40, vertical: AppSpacing.s24);
  }
  if (w >= 600) {
    return const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s20);
  }
  return const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16);
}

/// Extra bottom so scrollable content clears the bottom bar + iOS / Android home indicator in mobile browsers.
EdgeInsets pagePaddingForScreen(BuildContext context) {
  final mq = MediaQuery.of(context);
  final w = mq.size.width;
  final base = viewPaddingForWidth(w);
  final underNav = w < AppSpacing.railBreakpoint ? 20.0 : 0.0;
  return base + EdgeInsets.only(bottom: underNav + mq.viewPadding.bottom);
}
