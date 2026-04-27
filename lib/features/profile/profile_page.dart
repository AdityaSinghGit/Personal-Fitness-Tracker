// Profile form with save feedback: inline success strip + themed snackbar (no plain default toast).

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/features/profile/profile_bloc.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_feedback.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/util/app_theme.dart';
import 'package:personal_fitness_tracker/util/validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/widgets/glass_card.dart';
import 'package:personal_fitness_tracker/widgets/website/bento_feature_tile.dart';
import 'package:personal_fitness_tracker/widgets/website/section_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  FitnessGoal? _goal;
  bool _seeded = false;
  bool _saving = false;
  bool _showInlineSuccess = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoad());
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _commitSave(BuildContext c, ProfileReady s) async {
    if (_saving) {
      return;
    }
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(c).unfocus();
    setState(() {
      _saving = true;
      _showInlineSuccess = false;
    });
    final g = _goal ?? s.profile.goal;
    c.read<ProfileBloc>().add(
          ProfileSave(
            name: _name.text,
            age: int.parse(_age.text.trim()),
            goal: g,
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (!c.mounted) {
      return;
    }
    AppFeedback.success(c, 'Profile saved. Your coach and charts use the new details.');
    setState(() => _showInlineSuccess = true);
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (mounted) {
      setState(() => _showInlineSuccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext c, ProfileState s) {
        if (s is ProfileError) {
          AppFeedback.error(c, s.message);
        }
        if (s is ProfileReady && !_seeded) {
          _name.text = s.profile.name;
          _age.text = '${s.profile.age}';
          _goal = s.profile.goal;
          _seeded = true;
        }
      },
      builder: (BuildContext c, ProfileState s) {
        if (s is ProfileInitial || s is ProfileLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.accent));
        }
        if (s is ProfileError) {
          return Center(
            child: Text(s.message, style: const TextStyle(color: AppColors.error)),
          );
        }
        if (s is! ProfileReady) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (BuildContext c, BoxConstraints box) {
            final wide = box.maxWidth >= 900;
            return SingleChildScrollView(
              padding: pagePaddingForScreen(c),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWide),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _formColumn(c, s),
                            ),
                            const SizedBox(width: 28),
                            const Expanded(
                              child: Column(
                                children: <Widget>[
                                  BentoFeatureTile(
                                    icon: Icons.public_off_outlined,
                                    title: 'Local by design',
                                    subtitle: 'Name, age, and goal are stored in Hive. They only leave your machine if you call Gemini with your key from the coach tab.',
                                  ),
                                  SizedBox(height: 10),
                                  BentoFeatureTile(
                                    icon: Icons.school_outlined,
                                    title: 'Set expectations',
                                    subtitle: 'Picking a goal nudges the coach toward the tone you want — it is still general guidance, not a plan from a doctor.',
                                    accentColor: AppColors.accentSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _formColumn(c, s),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formColumn(BuildContext c, ProfileReady s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHeader(
          eyebrow: 'ABOUT YOU',
          title: 'Profile & long-term focus',
          subtitle: 'A light bio for charts and the coach. Change it any time; it rewrites the local file only.',
        ),
        const SizedBox(height: AppSpacing.s8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SuccessBanner(
              onDismiss: () {
                if (mounted) {
                  setState(() => _showInlineSuccess = false);
                }
              },
            ),
          ),
          crossFadeState: _showInlineSuccess ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        GlassCard(
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.s12),
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_saving) {
                      unawaited(_commitSave(c, s));
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: Validators.age,
                ),
                const SizedBox(height: AppSpacing.s12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Main goal',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<FitnessGoal>(
                      isExpanded: true,
                      value: _goal ?? s.profile.goal,
                      onChanged: _saving
                          ? null
                          : (FitnessGoal? g) => setState(() => _goal = g),
                      items: FitnessGoal.values
                          .map(
                            (FitnessGoal e) => DropdownMenuItem<FitnessGoal>(
                              value: e,
                              child: Text(e.shortLabel),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                FilledButton(
                  style: primaryFancyButtonStyle,
                  onPressed: _saving
                      ? null
                      : () {
                          unawaited(_commitSave(c, s));
                        },
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.onAccent,
                          ),
                        )
                      : const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline, dismissible “saved” confirmation (visible on small screens where snackbars are easy to miss).
class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.snackSuccess,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onDismiss,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              const Icon(Icons.check_rounded, color: AppColors.successBright, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saved on this device — your updates are in Hive.',
                  style: GoogleFonts.inter(
                    color: AppColors.snackOnSuccess,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
