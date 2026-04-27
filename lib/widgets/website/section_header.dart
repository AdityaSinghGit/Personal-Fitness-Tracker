// Reusable “eyebrow + title + optional subtitle” block for app pages to feel like product marketing.

import 'package:flutter/material.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/util/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (eyebrow != null) ...<Widget>[
          Text(eyebrow!.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: AppSpacing.s8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: AppSpacing.s8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ],
    );
  }
}
