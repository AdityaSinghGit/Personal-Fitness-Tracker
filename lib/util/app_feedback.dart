// Themed snackbars and lightweight confirmation patterns for mobile web + desktop.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';

class AppFeedback {
  AppFeedback._();

  static TextStyle get _messageStyle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  static EdgeInsets _edge(BuildContext context) {
    final m = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(12, 0, 12, 6 + m.viewPadding.bottom);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color background,
    required Color foreground,
    required IconData icon,
    Duration? duration,
  }) {
    if (!context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 22, color: foreground),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: _messageStyle.apply(color: foreground),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: _edge(context),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        duration: duration ?? const Duration(milliseconds: 3600),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.snackSuccess,
      foreground: AppColors.snackOnSuccess,
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.snackError,
      foreground: AppColors.snackOnError,
      icon: Icons.error_outline_rounded,
      duration: const Duration(milliseconds: 5000),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.snackInfo,
      foreground: AppColors.snackOnInfo,
      icon: Icons.tips_and_updates_outlined,
    );
  }
}
