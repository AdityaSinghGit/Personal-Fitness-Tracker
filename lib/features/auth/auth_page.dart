// Sign-in and sign-up with a product-style marketing column (hero, bento, trust) and the auth form.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/features/auth/auth_bloc.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/util/app_theme.dart';
import 'package:personal_fitness_tracker/util/app_feedback.dart';
import 'package:personal_fitness_tracker/util/app_typography.dart';
import 'package:personal_fitness_tracker/util/validators.dart';
import 'package:personal_fitness_tracker/widgets/ambient_background.dart';
import 'package:personal_fitness_tracker/widgets/glass_card.dart';
import 'package:personal_fitness_tracker/widgets/website/bento_feature_tile.dart';
import 'package:personal_fitness_tracker/widgets/website/site_footer.dart';
import 'package:personal_fitness_tracker/widgets/website/trust_pill.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  FitnessGoal _goal = FitnessGoal.stayActive;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(_onTab);
  }

  void _onTab() {
    if (!mounted) return;
    if (_tab.indexIsChanging) {
      return;
    }
    setState(() {});
    if (context.mounted) {
      context.read<AuthBloc>().add(const AuthFailureDismissed());
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_onTab);
    _tab.dispose();
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = context.watch<AuthBloc>().state;
    if (s is AuthUnauthenticated && s.emailHint != null && _email.text.isEmpty) {
      _email.text = s.emailHint!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState s) {
        if (s is AuthFailure) {
          AppFeedback.error(context, s.message);
        }
      },
      child: AmbientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints bc) {
              final w = bc.maxWidth;
              final twoCol = w >= AppSpacing.authTwoColumnAt;
              return Center(
                child: SingleChildScrollView(
                  padding: pagePaddingForScreen(context).copyWith(
                    top: AppSpacing.s32,
                    bottom: AppSpacing.s16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWide),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (twoCol) _twoColumnLayout(context, w) else _stackedLayout(context, w),
                        if (!twoCol) ...<Widget>[const SizedBox(height: AppSpacing.s40), _bentoValueSection(w)],
                        if (twoCol) const SizedBox(height: AppSpacing.s32),
                        const SiteFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _twoColumnLayout(BuildContext context, double w) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 52, child: _heroMarketing(context, w)),
        const SizedBox(width: 48),
        Expanded(
          flex: 48,
          child: _authCardFrame(context, maxW: 440),
        ),
      ],
    );
  }

  Widget _stackedLayout(BuildContext context, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _heroCompact(context, w),
        const SizedBox(height: AppSpacing.s32),
        _authCardFrame(context, maxW: 520),
      ],
    );
  }

  Widget _heroMarketing(BuildContext context, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _brandRow(),
        const SizedBox(height: AppSpacing.s32),
        Text('Train with clarity. Log with honesty. Coach with your key.', style: AppTypography.heroHeadline(w)),
        const SizedBox(height: AppSpacing.s20),
        Text(
          'LumaFit is a local-first web studio for movement and habits: profile, workouts, progress, and an optional Gemini guide — with guardrails, not medical claims.',
          style: AppTypography.heroSubline(context).copyWith(color: AppColors.textSecondary, fontSize: 17),
        ),
        const SizedBox(height: AppSpacing.s24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const <Widget>[
              TrustPill(icon: Icons.laptop_chromebook_outlined, text: 'Runs in your browser'),
              SizedBox(width: 10),
              TrustPill(icon: Icons.storage_outlined, text: 'Local Hive — no LumaFit cloud'),
              SizedBox(width: 10),
              TrustPill(icon: Icons.verified_user_outlined, text: 'You bring the Gemini key'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s32),
        const Text('Why it feels different', style: TextStyle(color: AppColors.textTertiary, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: AppSpacing.s12),
        _bentoValueSection(w, compact: true),
      ],
    );
  }

  Widget _heroCompact(BuildContext context, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _brandRow(),
        const SizedBox(height: AppSpacing.s24),
        Text('Clarity, logs & coach — on your device.', textAlign: TextAlign.center, style: AppTypography.heroHeadline(w)),
        const SizedBox(height: 12),
        Text(
          'No corporate fitness cloud: Hive + your Gemini key. General wellness only, not a doctor.',
          textAlign: TextAlign.center,
          style: AppTypography.heroSubline(context).copyWith(fontSize: 15, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const <Widget>[
              TrustPill(icon: Icons.download_done_outlined, text: 'Offline first'),
              TrustPill(icon: Icons.security_outlined, text: 'Encrypted key vault'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _brandRow() {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              colors: <Color>[AppColors.accentContainer.withValues(alpha: 0.5), AppColors.secondaryContainer.withValues(alpha: 0.45)],
            ),
          ),
          child: const Icon(Icons.fitness_center, color: AppColors.accent, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('LumaFit', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('STUDIO EDITION', style: GoogleFonts.inter(letterSpacing: 2, fontSize: 10, color: AppColors.accent)),
          ],
        ),
      ],
    );
  }

  /// Three-column bento; on compact hero, shows as vertical list of smaller tiles.
  Widget _bentoValueSection(double w, {bool compact = false}) {
    final child = w >= 800 && !compact
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: BentoFeatureTile(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Structured logging',
                  subtitle: 'Text how it felt, minutes moved, and build a local history you can show your coach in real life.',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: BentoFeatureTile(
                  icon: Icons.insights_outlined,
                  title: 'Progress you can read',
                  subtitle: 'Simple totals and 7-day rhythm — not vanity metrics, just a mirror of consistency.',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: BentoFeatureTile(
                  icon: Icons.psychology_outlined,
                  title: 'AI you control',
                  subtitle: 'Paste a Gemini key; we store it in an encrypted Hive box derived from your password. Not medical advice.',
                  accentColor: AppColors.accentLavender,
                ),
              ),
            ],
          )
        : Column(
            children: const <Widget>[
              BentoFeatureTile(
                icon: Icons.edit_calendar_outlined,
                title: 'Structured logging',
                subtitle: 'Minutes, how it felt, and a timeline that stays in your browser.',
              ),
              SizedBox(height: 10),
              BentoFeatureTile(
                icon: Icons.insights_outlined,
                title: 'Readable progress',
                subtitle: 'Totals and weekly pace — a calm dashboard, not a leaderboard.',
              ),
              SizedBox(height: 10),
              BentoFeatureTile(
                icon: Icons.psychology_outlined,
                title: 'Gemini, your key',
                subtitle: 'We never ship our API key; your vault reopens with your sign-in on this device.',
                accentColor: AppColors.accentLavender,
              ),
            ],
          );

    return child;
  }

  Widget _authCardFrame(BuildContext context, {required double maxW}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: GlassCard(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (BuildContext c, AuthState s) {
              return Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Get started', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Create a local account — nothing syncs to us.', style: Theme.of(context).textTheme.bodySmall),
                    if (s is AuthFailure) ...<Widget>[
                      const SizedBox(height: AppSpacing.s12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          s.message,
                          style: const TextStyle(color: AppColors.error, fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s20),
                    Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: TabBar(
                        controller: _tab,
                        indicator: BoxDecoration(
                          color: AppColors.accentContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textTertiary,
                        tabs: const <Widget>[
                          Tab(text: 'Sign in'),
                          Tab(text: 'Create account'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    if (_tab.index == 0) _buildSignIn(context, s) else _buildSignUp(context, s),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Your password unlocks a local encrypted vault for a Gemini key. A full refresh clears your session. Not medical software.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, AuthState s) {
    final busy = s is AuthLoading;
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _dismissFailure(context),
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
          validator: Validators.email,
        ),
        const SizedBox(height: AppSpacing.s12),
        TextFormField(
          controller: _pass,
          obscureText: _obscure,
          onChanged: (_) => _dismissFailure(context),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: Validators.password,
        ),
        const SizedBox(height: AppSpacing.s20),
        FilledButton(
          onPressed: busy
              ? null
              : () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  context.read<AuthBloc>().add(
                        AuthSignInRequested(email: _email.text, password: _pass.text),
                      );
                },
          style: primaryFancyButtonStyle,
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onAccent),
                  ),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }

  void _dismissFailure(BuildContext c) {
    if (c.read<AuthBloc>().state is AuthFailure) {
      c.read<AuthBloc>().add(const AuthFailureDismissed());
    }
  }

  Widget _buildSignUp(BuildContext context, AuthState s) {
    final busy = s is AuthLoading;
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => _dismissFailure(context),
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
          validator: Validators.email,
        ),
        const SizedBox(height: AppSpacing.s12),
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _dismissFailure(context),
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: Validators.name,
        ),
        const SizedBox(height: AppSpacing.s12),
        TextFormField(
          controller: _age,
          keyboardType: TextInputType.number,
          onChanged: (_) => _dismissFailure(context),
          decoration: const InputDecoration(
            labelText: 'Age',
            prefixIcon: Icon(Icons.cake_outlined),
          ),
          validator: Validators.age,
        ),
        const SizedBox(height: AppSpacing.s12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Goal',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FitnessGoal>(
              isExpanded: true,
              value: _goal,
              onChanged: busy
                  ? null
                  : (FitnessGoal? g) {
                      if (g == null) return;
                      setState(() => _goal = g);
                    },
              items: const <DropdownMenuItem<FitnessGoal>>[
                DropdownMenuItem(value: FitnessGoal.loseWeight, child: Text('Lose weight')),
                DropdownMenuItem(value: FitnessGoal.buildStrength, child: Text('Build strength')),
                DropdownMenuItem(value: FitnessGoal.stayActive, child: Text('Stay active')),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextFormField(
          controller: _pass,
          obscureText: _obscure,
          onChanged: (_) => _dismissFailure(context),
          decoration: InputDecoration(
            labelText: 'Password (min 8 characters)',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: Validators.password,
        ),
        const SizedBox(height: AppSpacing.s20),
        FilledButton(
          onPressed: busy
              ? null
              : () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final ageN = int.parse(_age.text.trim());
                  context.read<AuthBloc>().add(
                        AuthSignUpRequested(
                          email: _email.text,
                          password: _pass.text,
                          name: _name.text,
                          age: ageN,
                          goal: _goal,
                        ),
                      );
                },
          style: primaryFancyButtonStyle,
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onAccent),
                  ),
                )
              : const Text('Create & enter studio'),
        ),
      ],
    );
  }
}
