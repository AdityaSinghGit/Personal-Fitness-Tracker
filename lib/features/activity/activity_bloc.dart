// BLoC for listing and appending [ActivityLog] entries for the active user.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/data/models/activity_log.dart';
import 'package:personal_fitness_tracker/data/repositories/activity_repository.dart';

sealed class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class ActivityLoad extends ActivityEvent {
  const ActivityLoad();
}

class ActivityCleared extends ActivityEvent {
  const ActivityCleared();
}

class ActivityAdd extends ActivityEvent {
  const ActivityAdd({required this.title, required this.minutes, required this.feel1to5});
  final String title;
  final int minutes;
  final int feel1to5;
  @override
  List<Object?> get props => [title, minutes, feel1to5];
}

sealed class ActivityState extends Equatable {
  const ActivityState();
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityList extends ActivityState {
  const ActivityList(this.items);
  final List<ActivityLog> items;
  @override
  List<Object?> get props => [items];
}

class ActivityError extends ActivityState {
  const ActivityError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc(ActivityRepository repo) : _repo = repo, super(const ActivityInitial()) {
    on<ActivityLoad>(_onLoad);
    on<ActivityCleared>(_onCleared);
    on<ActivityAdd>(_onAdd);
  }
  final ActivityRepository _repo;

  void _onCleared(ActivityCleared e, Emitter<ActivityState> emit) {
    emit(const ActivityInitial());
  }

  Future<void> _onLoad(ActivityLoad e, Emitter<ActivityState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const ActivityError('Not signed in'));
      return;
    }
    emit(const ActivityLoading());
    emit(ActivityList(_repo.listForCurrentUser()));
  }

  Future<void> _onAdd(ActivityAdd e, Emitter<ActivityState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const ActivityError('Not signed in'));
      return;
    }
    final created = await _repo.add(
      title: e.title,
      minutes: e.minutes,
      feel1to5: e.feel1to5,
    );
    if (created == null) {
      emit(const ActivityError('Could not save activity. Try again.'));
    } else {
      emit(ActivityList(_repo.listForCurrentUser()));
    }
  }
}
