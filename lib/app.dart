// Root widget: repositories, BLoCs, theme, and auth → shell navigation.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/data/repositories/activity_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/auth_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/profile_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/secrets_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/settings_repository.dart';
import 'package:personal_fitness_tracker/features/activity/activity_bloc.dart' show ActivityBloc, ActivityCleared, ActivityLoad;
import 'package:personal_fitness_tracker/features/ai/ai_coach_bloc.dart' show AiCoachBloc, AiLoadKeyStatus, AiSessionLoggedOut;
import 'package:personal_fitness_tracker/features/auth/auth_bloc.dart';
import 'package:personal_fitness_tracker/features/auth/auth_page.dart';
import 'package:personal_fitness_tracker/features/profile/profile_bloc.dart' show ProfileBloc, ProfileCleared, ProfileLoad;
import 'package:personal_fitness_tracker/features/shell/app_shell.dart';
import 'package:personal_fitness_tracker/util/app_theme.dart';

/// Wires repositories and blocs; [initLocalStorage] must be called before this is built.
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = const SettingsRepository();
    final profileRepo = const ProfileRepository();
    final activityRepo = const ActivityRepository();
    final secretsRepo = SecretsRepository();
    final authRepo = AuthRepository(profileRepository: profileRepo, settingsRepository: settings);

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<SettingsRepository>.value(value: settings),
        RepositoryProvider<ProfileRepository>.value(value: profileRepo),
        RepositoryProvider<ActivityRepository>.value(value: activityRepo),
        RepositoryProvider<SecretsRepository>.value(value: secretsRepo),
        RepositoryProvider<AuthRepository>.value(value: authRepo),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(create: (BuildContext c) => AuthBloc(auth: c.read<AuthRepository>(), secrets: c.read<SecretsRepository>(), settings: c.read<SettingsRepository>())..add(const AuthStarted())),
          BlocProvider<ProfileBloc>(create: (BuildContext c) => ProfileBloc(c.read<ProfileRepository>())),
          BlocProvider<ActivityBloc>(create: (BuildContext c) => ActivityBloc(c.read<ActivityRepository>())),
          BlocProvider<AiCoachBloc>(create: (BuildContext c) => AiCoachBloc(secrets: c.read<SecretsRepository>(), profileRepository: c.read<ProfileRepository>(), activityRepository: c.read<ActivityRepository>())),
        ],
        child: MaterialApp(
          title: 'LumaFit',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const _AuthOrShell(),
        ),
      ),
    );
  }
}

class _AuthOrShell extends StatelessWidget {
  const _AuthOrShell();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState p, AuthState c) => p != c,
      listener: (BuildContext context, AuthState s) {
        if (s is AuthAuthenticated) {
          context.read<ProfileBloc>().add(const ProfileLoad());
          context.read<ActivityBloc>().add(const ActivityLoad());
          context.read<AiCoachBloc>().add(const AiLoadKeyStatus());
        } else if (s is AuthUnauthenticated) {
          context.read<ProfileBloc>().add(const ProfileCleared());
          context.read<ActivityBloc>().add(const ActivityCleared());
          context.read<AiCoachBloc>().add(const AiSessionLoggedOut());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (AuthState a, AuthState b) => a != b,
        builder: (BuildContext context, AuthState s) {
          if (s is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
            );
          }
          if (s is AuthAuthenticated) {
            return const AppShell();
          }
          return const AuthPage();
        },
      ),
    );
  }
}
