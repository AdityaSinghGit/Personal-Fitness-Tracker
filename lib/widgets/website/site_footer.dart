// Lightweight site footer: positioning copy + ethics reminder — common on modern marketing web apps.

import 'package:flutter/material.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.inter(
      color: AppColors.textTertiary,
      fontSize: 12,
      height: 1.5,
    );
    return Semantics(
      label: 'Site information',
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.s64,
          bottom: AppSpacing.s32,
        ),
        child: Column(
          children: <Widget>[
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.s24),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: <Widget>[
                const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.textTertiary),
                Text('Your data lives in the browser (Hive) — we don’t run a server for your account.', style: textStyle),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'LumaFit is general wellness software, not a medical device. AI output is for inspiration only. Built with Flutter.',
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
