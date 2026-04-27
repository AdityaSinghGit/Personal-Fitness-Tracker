// BLoC for sign-in, sign-up, and sign-out, coordinating [AuthRepository] and [SecretsRepository].

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/data/repositories/auth_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/secrets_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/settings_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.goal,
  });
  final String email;
  final String password;
  final String name;
  final int age;
  final FitnessGoal goal;
  @override
  List<Object?> get props => [email, password, name, age, goal];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthFailureDismissed extends AuthEvent {
  const AuthFailureDismissed();
}

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.emailHint});
  final String? emailHint;
  @override
  List<Object?> get props => [emailHint];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.email);
  final String email;
  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message, {this.emailHint});
  final String message;
  final String? emailHint;
  @override
  List<Object?> get props => [message, emailHint];
}

/// Drives the auth flow and keeps [AppSession] and the encrypted vault in sync.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository auth, required SecretsRepository secrets, required SettingsRepository settings})
    : _auth = auth,
      _secrets = secrets,
      _settings = settings,
      super(const AuthUnauthenticated()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthFailureDismissed>(_onFailureDismissed);
  }

  final AuthRepository _auth;
  final SecretsRepository _secrets;
  final SettingsRepository _settings;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    if (AppSession.instance.isAuthenticated) {
      emit(AuthAuthenticated(AppSession.instance.email!));
    } else {
      emit(AuthUnauthenticated(emailHint: _settings.lastEmailHint));
    }
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    await _secrets.closeVault();
    AppSession.instance.clear();
    emit(const AuthLoading());
    final err = await _auth.signIn(email: event.email, password: event.password);
    if (err != null) {
      emit(AuthFailure(err, emailHint: _settings.lastEmailHint));
    } else {
      emit(AuthAuthenticated(AppSession.instance.email!));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    await _secrets.closeVault();
    AppSession.instance.clear();
    emit(const AuthLoading());
    final err = await _auth.signUp(
      email: event.email,
      password: event.password,
      name: event.name,
      age: event.age,
      goal: event.goal,
    );
    if (err != null) {
      emit(AuthFailure(err, emailHint: _settings.lastEmailHint));
    } else {
      emit(AuthAuthenticated(AppSession.instance.email!));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _secrets.closeVault();
    AppSession.instance.clear();
    emit(AuthUnauthenticated(emailHint: _settings.lastEmailHint));
  }

  void _onFailureDismissed(AuthFailureDismissed event, Emitter<AuthState> emit) {
    if (state is AuthFailure) {
      emit(AuthUnauthenticated(emailHint: (state as AuthFailure).emailHint));
    }
  }
}
