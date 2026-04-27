// Progress view: headline stats, 7-day rhythm strip, and recent activity — reads like a small analytics page.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_fitness_tracker/data/models/activity_log.dart';
import 'package:personal_fitness_tracker/features/activity/activity_bloc.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_feedback.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/widgets/glass_card.dart';
import 'package:personal_fitness_tracker/widgets/website/section_header.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(const ActivityLoad());
  }

  /// Pull to refresh: reload activities; load errors show as a floating snack.
  Future<void> _refresh() async {
    if (!mounted) {
      return;
    }
    final b = context.read<ActivityBloc>();
    b.add(const ActivityLoad());
    final next = await b.stream.firstWhere(
      (ActivityState e) => e is ActivityList || e is ActivityError,
    );
    if (!mounted) {
      return;
    }
    if (next is ActivityError) {
      AppFeedback.error(context, next.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (BuildContext c, ActivityState s) {
        final List<ActivityLog> items = s is ActivityList
            ? s.items
            : s is ActivityError
                ? const <ActivityLog>[]
                : const <ActivityLog>[];
        final int totalMin = items.fold<int>(0, (int t, ActivityLog a) => t + a.minutes);
        final int totalSessions = items.length;
        final int avgMin = totalSessions == 0 ? 0 : (totalMin / totalSessions).round();
        final DateTime now = DateTime.now();
        final DateTime weekAgo = now.subtract(const Duration(days: 7));
        final int thisWeek = items
            .where(
              (ActivityLog a) => a.loggedAt.isAfter(weekAgo.toUtc()),
            )
            .length;
        final List<int> last7 = _last7DayCounts(items);
        final int maxD = last7.reduce((int a, int b) => a > b ? a : b);

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceElevated,
          strokeWidth: 2.4,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: pagePaddingForScreen(c),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SectionHeader(
                      eyebrow: 'INSIGHTS',
                      title: 'Progress & insights',
                      subtitle: 'A quick read of what you have already done — not a test. Missed days are part of the pattern.',
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    if (s is ActivityError) _InlineErrorBanner(message: s.message),
                    if (s is ActivityLoading || s is ActivityInitial) ...<Widget>[
                      GlassCard(
                        child: const LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                    ],
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: <Widget>[
                        _InsightBox(
                          label: 'Total minutes',
                          valueText: totalMin.toString(),
                          caption: 'All time',
                          icon: Icons.timelapse_rounded,
                          hot: true,
                        ),
                        _InsightBox(
                          label: 'Sessions',
                          valueText: totalSessions.toString(),
                          caption: 'Logged in app',
                          icon: Icons.assignment_outlined,
                          hot: false,
                        ),
                        _InsightBox(
                          label: 'Typical length',
                          valueText: totalSessions == 0 ? '—' : '$avgMin min',
                          caption: 'Per session (avg.)',
                          icon: Icons.straighten,
                          hot: false,
                        ),
                        _InsightBox(
                          label: '7-day pace',
                          valueText: thisWeek.toString(),
                          caption: 'Sessions this week',
                          icon: Icons.bolt,
                          hot: thisWeek > 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    const SectionHeader(
                      eyebrow: 'RHYTHM',
                      title: 'Last 7 days',
                      subtitle: 'Taller = more days you logged. Today is on the right; it has a light ring. Hover (desktop) or long-press a bar to see the count.',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _SevenDayStrip(dayCounts: last7, maxD: maxD),
                    if (items.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.s32),
                      const SectionHeader(
                        eyebrow: 'FEED',
                        title: 'Recent sessions',
                        subtitle: 'Newest first — mirrors your activity log.',
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ...items.take(10).map(
                            (ActivityLog a) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SessionRow(a: a),
                            ),
                          ),
                    ] else if (s is! ActivityError && s is! ActivityInitial && s is! ActivityLoading) ...<Widget>[
                      const SizedBox(height: AppSpacing.s16),
                      const _EmptyProgressCta(),
                    ] else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// —— Screen widgets ———————————————————————————————————————

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.error, fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox({
    required this.label,
    required this.valueText,
    required this.caption,
    required this.icon,
    this.hot = false,
  });

  final String label;
  final String valueText;
  final String caption;
  final IconData icon;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 152, maxWidth: 300),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
                gradient: hot
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[AppColors.accent, AppColors.accentDim],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.accent.withValues(alpha: 0.3),
                          AppColors.textTertiary.withValues(alpha: 0.2),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (hot ? AppColors.accent : AppColors.textTertiary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (hot ? AppColors.accent : AppColors.border).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: hot ? AppColors.accent : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.65,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.55,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SevenDayStrip extends StatelessWidget {
  const _SevenDayStrip({required this.dayCounts, required this.maxD});
  final List<int> dayCounts;
  final int maxD;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(7, (int i) {
          final DateTime d = DateTime.now().subtract(Duration(days: 6 - i));
          final int count = i < dayCounts.length ? dayCounts[i] : 0;
          final String label = DateFormat('EEE').format(d);
          final bool isToday = i == 6;
          final double h = maxD == 0
              ? 8.0
              : (64 * (count / maxD)).clamp(8.0, 72.0);
          return Expanded(
            child: _DayBar(
              label: label,
              isToday: isToday,
              count: count,
              maxHeight: h,
            ),
          );
        }),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.isToday,
    required this.count,
    required this.maxHeight,
  });

  final String label;
  final bool isToday;
  final int count;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final String tip = isToday
        ? 'Today: $count ${count == 1 ? "session" : "sessions"}'
        : '$label: $count ${count == 1 ? "session" : "sessions"}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: tip,
        child: Semantics(
          label: tip,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                count.toString(),
                style: GoogleFonts.inter(
                  color: isToday ? AppColors.accentSecondary : AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 80,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: double.infinity,
                    height: maxHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: AppColors.accent.withValues(alpha: 0.9),
                              width: 1.4,
                            )
                          : null,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[AppColors.accentContainer, AppColors.accent, AppColors.accentDim],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isToday ? AppColors.accentSecondary : AppColors.textTertiary,
                  fontSize: 10.5,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isToday) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  'Now',
                  style: GoogleFonts.inter(
                    color: AppColors.accent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.a});
  final ActivityLog a;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: a.feel1to5 >= 4 ? AppColors.accent : AppColors.textTertiary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  a.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${a.minutes} min · Felt ${a.feel1to5}/5',
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            DateFormat('EEE M/d').format(a.loggedAt.toLocal()),
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgressCta extends StatelessWidget {
  const _EmptyProgressCta();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.accentContainer.withValues(alpha: 0.4),
            ),
            child: const Icon(Icons.stacked_line_chart, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Add one log in the workout page and you will see a rhythm strip and a richer feed here.',
              style: GoogleFonts.inter(
                color: AppColors.textTertiary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<int> _last7DayCounts(List<ActivityLog> items) {
  final DateTime now = DateTime.now();
  final DateTime startOfToday = DateTime(now.year, now.month, now.day);
  final DateTime start = startOfToday.subtract(const Duration(days: 6));
  final List<int> counts = List<int>.filled(7, 0);
  for (final ActivityLog a in items) {
    final DateTime local = a.loggedAt.toLocal();
    final DateTime d = DateTime(local.year, local.month, local.day);
    if (d.isBefore(start) || d.isAfter(startOfToday)) {
      continue;
    }
    final int i = d.difference(start).inDays;
    if (i >= 0 && i < 7) {
      counts[i] += 1;
    }
  }
  return counts;
}
