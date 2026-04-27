// Log activities: on wide screens, form and history sit side by side like a product dashboard.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/data/models/activity_log.dart';
import 'package:personal_fitness_tracker/features/activity/activity_bloc.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_feedback.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/util/app_theme.dart';
import 'package:personal_fitness_tracker/util/validators.dart';
import 'package:personal_fitness_tracker/widgets/glass_card.dart';
import 'package:personal_fitness_tracker/widgets/website/section_header.dart';

class LogActivityPage extends StatefulWidget {
  const LogActivityPage({super.key});

  @override
  State<LogActivityPage> createState() => _LogActivityPageState();
}

class _LogActivityPageState extends State<LogActivityPage> {
  static const List<String> _presets = <String>[
    '30m walk',
    'Zone-2 run',
    'Upper-body lift',
    'Yoga flow',
    'Stretch & mobility',
  ];

  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _minutes = TextEditingController();
  int _feel = 3;
  /// True after [ActivityAdd] is dispatched until we get [ActivityList] or [ActivityError].
  bool _awaitingAdd = false;

  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(const ActivityLoad());
  }

  @override
  void dispose() {
    _title.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _onActivityState(BuildContext c, ActivityState s) {
    if (!_awaitingAdd) {
      return;
    }
    if (s is ActivityList) {
      if (!c.mounted) {
        return;
      }
      AppFeedback.success(c, 'Nice — that’s logged. Keep the streak going.');
      setState(() {
        _awaitingAdd = false;
        _title.clear();
        _minutes.clear();
        _feel = 3;
        _form.currentState?.reset();
      });
    } else if (s is ActivityError) {
      if (!c.mounted) {
        return;
      }
      AppFeedback.error(c, s.message);
      setState(() => _awaitingAdd = false);
    }
  }

  /// Pull-to-refresh: waits until load resolves, then shows errors in a snack.
  Future<void> _refreshActivities() async {
    if (!mounted) {
      return;
    }
    if (_awaitingAdd) {
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

  void _trySubmit(BuildContext c) {
    FocusScope.of(c).unfocus();
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _awaitingAdd = true);
    c.read<ActivityBloc>().add(
          ActivityAdd(
            title: _title.text,
            minutes: int.parse(_minutes.text.trim()),
            feel1to5: _feel.clamp(1, 5),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listenWhen: (ActivityState p, ActivityState c) {
        if (!_awaitingAdd) {
          return false;
        }
        return c is ActivityList || c is ActivityError;
      },
      listener: _onActivityState,
      builder: (BuildContext c, ActivityState s) {
        return LayoutBuilder(
          builder: (BuildContext c, BoxConstraints box) {
            final wide = box.maxWidth >= 960;
            final formBlock = _formCard(c, s);
            final historyBlock = _historyBlock(c, s);
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surfaceElevated,
              strokeWidth: 2.4,
              onRefresh: _refreshActivities,
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
                          eyebrow: 'JOURNAL',
                          title: 'Workout & activity log',
                          subtitle:
                              'Name the work, time it, and tap how it felt. Patterns show up in Progress (no extra gadgets).',
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(flex: 48, child: formBlock),
                              const SizedBox(width: 24),
                              Expanded(flex: 52, child: historyBlock),
                            ],
                          )
                        else ...<Widget>[
                          formBlock,
                          const SizedBox(height: AppSpacing.s32),
                          historyBlock,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _labelForFeel(int f) {
    return switch (f) {
      1 => 'Rough',
      2 => 'Low',
      3 => 'OK',
      4 => 'Good',
      5 => 'Great',
      _ => 'OK',
    };
  }

  Widget _formCard(BuildContext c, ActivityState s) {
    final canSubmit = !_awaitingAdd && s is! ActivityLoading;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _FormHeroHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s24),
            child: Form(
              key: _form,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.s4),
                  Text('Quick start', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                  const SizedBox(height: AppSpacing.s8),
                  LayoutBuilder(
                    builder: (BuildContext _, BoxConstraints c2) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presets
                            .map(
                              (String t) => ActionChip(
                                label: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                onPressed: () {
                                  setState(() => _title.text = t);
                                },
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: const BorderSide(color: AppColors.border),
                                backgroundColor: AppColors.surface,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'What did you do?',
                      hintText: 'e.g. 20 min mobility + 10 min core',
                      prefixIcon: Icon(Icons.fitness_center_outlined),
                    ),
                    validator: Validators.activityTitle,
                    onFieldSubmitted: (_) {
                      if (_minutes.text.isEmpty) {
                        return;
                      }
                      if (canSubmit) {
                        _trySubmit(c);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    validator: Validators.activityMinutes,
                    onFieldSubmitted: (_) {
                      if (canSubmit) {
                        _trySubmit(c);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text('How it felt', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Tap a level — “${_labelForFeel(_feel)}” (${_feel.toString()}/5)',
                    style: Theme.of(c).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _FeelRuler(
                    value: _feel,
                    onChanged: (int v) => setState(() => _feel = v),
                    labelFor: _labelForFeel,
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  FilledButton(
                    style: primaryFancyButtonStyle,
                    onPressed: canSubmit
                        ? () {
                            _trySubmit(c);
                          }
                        : null,
                    child: _awaitingAdd
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.onAccent,
                            ),
                          )
                        : const Text('Log to timeline'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeOrShort(DateTime t) {
    final local = t.toLocal();
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final d = DateTime(local.year, local.month, local.day);
    if (d == today) {
      return 'Today';
    }
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('EEE, MMM d').format(local);
  }

  Widget _historyBlock(BuildContext c, ActivityState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Your timeline', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Most recent first. Pull to refresh on your phone.',
            style: Theme.of(c).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.s16),
        if (s is ActivityInitial || s is ActivityLoading) ...<Widget>[
          GlassCard(
            child: const LinearProgressIndicator(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              minHeight: 3,
              color: AppColors.accent,
            ),
          ),
        ] else if (s is ActivityList && s.items.isNotEmpty) ...<Widget>[
          ...s.items.asMap().entries.map(
            (MapEntry<int, ActivityLog> e) {
              final ActivityLog a = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TimelineEntryCard(
                  isNewest: e.key == 0,
                  title: a.title,
                  minutes: a.minutes,
                  feel: a.feel1to5,
                  dateText: _formatRelativeOrShort(a.loggedAt.toLocal()),
                ),
              );
            },
          ),
        ] else if (s is ActivityList && s.items.isEmpty) ...<Widget>[
          _emptyTimeline(c),
        ] else if (s is ActivityError) ...<Widget>[
          GlassCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(s.message, style: const TextStyle(color: AppColors.error, fontSize: 14, height: 1.4))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _emptyTimeline(BuildContext c) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.rocket_launch_outlined, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Start in one minute', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  'Add a walk, a stretch, or a full session — small logs still count.',
                  style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// —— Sub-widgets: hero strip + feel ruler + timeline row (kept private to this file). ——

/// Gradient hero strip and title for the log form (visual anchor on mobile + web).
class _FormHeroHeader extends StatelessWidget {
  const _FormHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'New log entry',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 18, AppSpacing.s20, 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.cardRadius - 0.5),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.accentContainer,
                AppColors.secondaryContainer.withValues(alpha: 0.4),
                AppColors.surface,
              ],
            ),
          ),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.bolt, color: AppColors.accent, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('New entry', style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text('Fast to tap, easy to read later.', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 12.5, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1–5 tappable “feel” steps with large hit targets (mobile web friendly).
class _FeelRuler extends StatelessWidget {
  const _FeelRuler({
    required this.value,
    required this.onChanged,
    required this.labelFor,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String Function(int) labelFor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'How the session felt, 1 to 5, currently ${labelFor(value)}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(5, (int i) {
          final n = i + 1;
          final selected = value == n;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < 4 ? 6 : 0,
              ),
              child: Semantics(
                label: 'Feel level $n, ${labelFor(n)}',
                button: true,
                selected: selected,
                child: Material(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onChanged(n),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border.withValues(alpha: 0.5),
                          width: selected ? 1.4 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          n.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: selected ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TimelineEntryCard extends StatelessWidget {
  const _TimelineEntryCard({
    required this.isNewest,
    required this.title,
    required this.minutes,
    required this.feel,
    required this.dateText,
  });

  final bool isNewest;
  final String title;
  final int minutes;
  final int feel;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Activity $title, $minutes minutes, felt $feel of 5, on $dateText',
      child: Material(
        color: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 3,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[AppColors.accentSecondary, AppColors.accent],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$minutes min · Felt $feel/5',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    dateText,
                    style: GoogleFonts.inter(
                      color: feel >= 4 ? AppColors.accentSecondary : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isNewest) ...<Widget>[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LATEST',
                        style: GoogleFonts.inter(
                          color: AppColors.accentAmberPill,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
