// AI coach: split “setup” + chat on large web widths; one column on phones.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/features/ai/ai_coach_bloc.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/util/app_theme.dart';
import 'package:personal_fitness_tracker/util/app_feedback.dart';
import 'package:personal_fitness_tracker/util/validators.dart';
import 'package:personal_fitness_tracker/widgets/glass_card.dart';
import 'package:personal_fitness_tracker/widgets/website/bento_feature_tile.dart';
import 'package:personal_fitness_tracker/widgets/website/section_header.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _keyCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (AppSession.instance.isAuthenticated) {
      context.read<AiCoachBloc>().add(const AiLoadKeyStatus());
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiCoachBloc, AiState>(
      listener: (BuildContext c, AiState s) {
        if (s is AiError) {
          AppFeedback.error(c, s.message);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
      },
      builder: (BuildContext c, AiState s) {
        if (s is AiUnauthenticated) {
          return const Center(
            child: Text('Sign in to use the coach and save a key in your local vault.', textAlign: TextAlign.center),
          );
        }
        if (s is AiError) {
          return _bodyForLayout(
            c,
            s.hasKeyOnDevice,
            s.history,
            busy: false,
          );
        }
        if (s is AiWorking) {
          return _bodyForLayout(c, s.hasKeyOnDevice, s.history, busy: true);
        }
        if (s is AiIdle) {
          return _bodyForLayout(c, s.hasKeyOnDevice, s.history);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _bodyForLayout(
    BuildContext c,
    bool hasKey,
    List<ChatTurn> history, {
    bool busy = false,
  }) {
    final w = MediaQuery.sizeOf(c).width;
    final wide = w > 1000;
    if (!wide) {
      return _oneColumn(
        c,
        hasKey,
        history,
        busy: busy,
        pad: pagePaddingForScreen(c),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 380,
          child: ColoredBox(
            color: AppColors.surface.withValues(alpha: 0.35),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s24),
              child: _leftColumn(c, hasKey),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
        Expanded(
          child: _oneColumn(
            c,
            hasKey,
            history,
            busy: busy,
            showHeader: false,
            showKey: false,
            pad: pagePaddingForScreen(c).copyWith(left: 20, right: 32, top: 12),
          ),
        ),
      ],
    );
  }

  Widget _leftColumn(BuildContext c, bool hasKey) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionHeader(
            eyebrow: 'SETUP',
            title: 'Connect Gemini',
            subtitle: 'Google AI Studio key — stored only in an encrypted Hive vault on this machine.',
          ),
          const SizedBox(height: 16),
          _keyCard(c, hasKey),
          const SizedBox(height: 16),
          const BentoFeatureTile(
            icon: Icons.gavel_outlined,
            title: 'Safety first',
            subtitle: 'We block some topics client-side, add API safety, and a strict system prompt — still, treat answers as non-medical.',
            accentColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _keyCard(BuildContext c, bool hasKey) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.key, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text('Gemini API key', style: Theme.of(c).textTheme.labelLarge),
              const Spacer(),
              if (hasKey) Text('Saved', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          TextFormField(
            controller: _keyCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Paste key',
              hintText: 'AIza…',
            ),
            validator: (String? v) {
              if (v == null || v.isEmpty) {
                return 'Save a key to chat, or get one from Google AI Studio.';
              }
              return Validators.optionalGeminiKey(v);
            },
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: () {
                  final t = _keyCtrl.text;
                  if (t.trim().isEmpty) {
                AppFeedback.info(c, 'Get a key from Google AI Studio, then paste and save here.');
                    return;
                  }
                  c.read<AiCoachBloc>().add(AiSaveKey(t));
                },
                style: primaryFancyButtonStyle,
                child: const Text('Save key locally'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => c.read<AiCoachBloc>().add(const AiClearKey()),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _oneColumn(
    BuildContext c,
    bool hasKey,
    List<ChatTurn> history, {
    bool busy = false,
    bool showHeader = true,
    bool showKey = true,
    required EdgeInsets pad,
  }) {
    return CustomScrollView(
      controller: _scroll,
      slivers: <Widget>[
        SliverPadding(
          padding: pad,
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                if (showHeader) ...<Widget>[
                  const SectionHeader(
                    eyebrow: 'COACH',
                    title: 'AI assistant (Gemini)',
                    subtitle: 'Bring your key; we stream guidance that respects the guardrails. Not a clinician.',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                ],
                if (showKey) ...<Widget>[
                  _keyCard(c, hasKey),
                  const SizedBox(height: AppSpacing.s20),
                ],
                Row(
                  children: <Widget>[
                    Text('Conversation', style: Theme.of(c).textTheme.titleLarge),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => c.read<AiCoachBloc>().add(const AiNewChat()),
                      child: const Text('New session'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final turn in history) Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _bubble(c, turn),
                ),
                if (busy) const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(borderRadius: BorderRadius.all(Radius.circular(4)), minHeight: 3, color: AppColors.accent),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _msgCtrl,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: busy ? null : (_) => _send(c, busy),
                  textInputAction: TextInputAction.send,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Ask about habits, form cues, or weekly structure',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy ? null : () => _send(c, busy),
                  style: primaryFancyButtonStyle,
                  child: const Text('Send to coach'),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _send(BuildContext c, bool busy) {
    if (busy) {
      return;
    }
    FocusScope.of(c).unfocus();
    c.read<AiCoachBloc>().add(AiSendUserMessage(_msgCtrl.text));
    _msgCtrl.clear();
  }

  Widget _bubble(BuildContext c, ChatTurn t) {
    if (t.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: AppColors.accentContainer.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(t.text, style: const TextStyle(height: 1.4)),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          t.wasGuardrail ? 'Notice: ${t.text}' : t.text,
          style: TextStyle(height: 1.45, color: t.wasGuardrail ? AppColors.error : AppColors.textPrimary, fontSize: 14.5),
        ),
      ),
    );
  }
}
