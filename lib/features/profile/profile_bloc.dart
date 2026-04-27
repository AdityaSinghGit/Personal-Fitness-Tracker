// BLoC for the local [UserProfile]: load and save to Hive for the current session.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/data/models/user_profile.dart';
import 'package:personal_fitness_tracker/data/repositories/profile_repository.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
}

class ProfileCleared extends ProfileEvent {
  const ProfileCleared();
}

class ProfileSave extends ProfileEvent {
  const ProfileSave({required this.name, required this.age, required this.goal});
  final String name;
  final int age;
  final FitnessGoal goal;
  @override
  List<Object?> get props => [name, age, goal];
}

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileReady extends ProfileState {
  const ProfileReady(this.profile);
  final UserProfile profile;
  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

/// Loads and persists profile data for the signed-in user.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(ProfileRepository repo) : _repo = repo, super(const ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileCleared>(_onCleared);
    on<ProfileSave>(_onSave);
  }
  final ProfileRepository _repo;

  void _onCleared(ProfileCleared e, Emitter<ProfileState> emit) {
    emit(const ProfileInitial());
  }

  Future<void> _onLoad(ProfileLoad e, Emitter<ProfileState> emit) async {
    final email = AppSession.instance.email;
    if (email == null) {
      emit(const ProfileError('Not signed in'));
      return;
    }
    emit(const ProfileLoading());
    var p = _repo.profileFor(email);
    p ??= UserProfile(
      name: 'Athlete',
      age: 30,
      goal: FitnessGoal.stayActive,
    );
    if (_repo.profileFor(email) == null) {
      await _repo.saveProfileForEmail(email, p);
    }
    emit(ProfileReady(p));
  }

  Future<void> _onSave(ProfileSave e, Emitter<ProfileState> emit) async {
    final email = AppSession.instance.email;
    if (email == null) {
      emit(const ProfileError('Not signed in'));
      return;
    }
    final p = UserProfile(name: e.name, age: e.age, goal: e.goal);
    await _repo.saveProfileForEmail(email, p);
    emit(ProfileReady(p));
  }
}
