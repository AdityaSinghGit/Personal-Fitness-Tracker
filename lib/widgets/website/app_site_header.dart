// Sticky product-style top bar: brand lockup + current section (wide layouts) + tappable LumaFit brand to reload the active screen.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';

const List<String> kSectionHeadings = <String>['Profile & goals', 'Workout log', 'Progress & insights', 'AI coach'];

/// App bar title on narrow viewports: icon + name + subline, tappable to soft-reload the current tab.
class LumaFitAppBarTitle extends StatelessWidget {
  const LumaFitAppBarTitle({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LumaFitBrandRow(
      compact: true,
      onTap: onTap,
    );
  }
}

/// Tappable LumaFit lockup: icon, wordmark, optional subline. Used in [AppSiteHeader] and the mobile [AppBar].
class LumaFitBrandRow extends StatelessWidget {
  const LumaFitBrandRow({
    super.key,
    this.onTap,
    this.compact = false,
  });

  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sub = !compact
        ? (w >= 800 ? 'Personal fitness · offline-first' : 'Offline-first')
        : 'Offline-first · your browser';

    void handleTap() {
      onTap?.call();
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.accent,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LumaFit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                sub,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: compact ? 12 : 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) {
      return child;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: AppColors.accent.withValues(alpha: 0.08),
        splashColor: AppColors.accent.withValues(alpha: 0.12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Thin header shown above the [NavigationRail] on large web viewports.
class AppSiteHeader extends StatelessWidget {
  const AppSiteHeader({super.key, required this.sectionIndex, this.actions, this.onBrandTap});

  final int sectionIndex;
  final List<Widget>? actions;
  final VoidCallback? onBrandTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.55),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: Row(
          children: <Widget>[
            LumaFitBrandRow(onTap: onBrandTap),
            const Spacer(),
            if (sectionIndex >= 0 && sectionIndex < kSectionHeadings.length) ...<Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  kSectionHeadings[sectionIndex],
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (actions != null && actions!.isNotEmpty) const SizedBox(width: AppSpacing.s16),
            ],
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
