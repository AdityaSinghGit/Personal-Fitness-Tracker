// BLoC for the Gemini chat: key lifecycle, preflight, and a short history of this session only.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:personal_fitness_tracker/core/ai/ai_safety.dart';
import 'package:personal_fitness_tracker/core/ai/gemini_fitness_client.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/data/models/user_profile.dart';
import 'package:personal_fitness_tracker/data/repositories/activity_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/profile_repository.dart';
import 'package:personal_fitness_tracker/data/repositories/secrets_repository.dart';

sealed class AiEvent extends Equatable {
  const AiEvent();
  @override
  List<Object?> get props => [];
}

class AiLoadKeyStatus extends AiEvent {
  const AiLoadKeyStatus();
}

class AiSaveKey extends AiEvent {
  const AiSaveKey(this.apiKey);
  final String apiKey;
  @override
  List<Object?> get props => [apiKey];
}

class AiClearKey extends AiEvent {
  const AiClearKey();
}

class AiSendUserMessage extends AiEvent {
  const AiSendUserMessage(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class AiNewChat extends AiEvent {
  const AiNewChat();
}

class AiSessionLoggedOut extends AiEvent {
  const AiSessionLoggedOut();
}

/// One row in the chat transcript (in-memory; cleared on refresh or new chat).
class ChatTurn extends Equatable {
  const ChatTurn({required this.isUser, required this.text, this.wasGuardrail = false});
  final bool isUser;
  final String text;
  final bool wasGuardrail;
  @override
  List<Object?> get props => [isUser, text, wasGuardrail];
}

sealed class AiState extends Equatable {
  const AiState();
  @override
  List<Object?> get props => [];
}

class AiUnauthenticated extends AiState {
  const AiUnauthenticated();
}

class AiIdle extends AiState {
  const AiIdle({
    required this.hasKeyOnDevice,
    required this.history,
  });
  final bool hasKeyOnDevice;
  final List<ChatTurn> history;
  @override
  List<Object?> get props => [hasKeyOnDevice, history];
}

class AiWorking extends AiState {
  const AiWorking({required this.hasKeyOnDevice, required this.history});
  final bool hasKeyOnDevice;
  final List<ChatTurn> history;
  @override
  List<Object?> get props => [hasKeyOnDevice, history];
}

class AiError extends AiState {
  const AiError(this.message, {this.hasKeyOnDevice = true, this.history = const <ChatTurn>[]});
  final String message;
  final bool hasKeyOnDevice;
  final List<ChatTurn> history;
  @override
  List<Object?> get props => [message, hasKeyOnDevice, history];
}

/// Coordinates the assistant UI and outbound Gemini calls (user API key only).
class AiCoachBloc extends Bloc<AiEvent, AiState> {
  AiCoachBloc({
    required SecretsRepository secrets,
    required ProfileRepository profileRepository,
    required ActivityRepository activityRepository,
  }) : _secrets = secrets,
       _profile = profileRepository,
       _activity = activityRepository,
       super(const AiIdle(hasKeyOnDevice: false, history: <ChatTurn>[])) {
    on<AiLoadKeyStatus>(_onLoad);
    on<AiSaveKey>(_onSave);
    on<AiClearKey>(_onClear);
    on<AiSendUserMessage>(_onSend);
    on<AiNewChat>(_onNew);
    on<AiSessionLoggedOut>(_onSessionOut);
  }
  final SecretsRepository _secrets;
  final ProfileRepository _profile;
  final ActivityRepository _activity;

  Future<void> _onLoad(AiLoadKeyStatus e, Emitter<AiState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const AiUnauthenticated());
      return;
    }
    final k = await _secrets.readGeminiKey();
    final has = k != null && k.trim().isNotEmpty;
    final h = _historyFrom(state);
    emit(
      AiIdle(
        hasKeyOnDevice: has,
        history: h.isNotEmpty
            ? h
            : <ChatTurn>[
                ChatTurn(
                  isUser: false,
                  text: 'Paste your own Gemini key above (encrypted on this device). I’m a coach, not a doctor — I’ll be honest about what I can’t do.',
                  wasGuardrail: false,
                ),
              ],
      ),
    );
  }

  void _onSessionOut(AiSessionLoggedOut e, Emitter<AiState> emit) {
    emit(const AiIdle(hasKeyOnDevice: false, history: <ChatTurn>[]));
  }

  List<ChatTurn> _historyFrom(AiState s) {
    if (s is AiIdle) return s.history;
    if (s is AiWorking) return s.history;
    if (s is AiError) return s.history;
    return const <ChatTurn>[];
  }

  bool _keyFlagFrom(AiState s) {
    if (s is AiIdle) return s.hasKeyOnDevice;
    if (s is AiWorking) return s.hasKeyOnDevice;
    if (s is AiError) return s.hasKeyOnDevice;
    return false;
  }

  Future<void> _onSave(AiSaveKey e, Emitter<AiState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const AiError('Sign in to save a key on this device'));
      return;
    }
    final err = await _secrets.writeGeminiKey(e.apiKey);
    if (err != null) {
      emit(AiError(err, hasKeyOnDevice: false, history: _historyFrom(state)));
    } else {
      emit(
        AiIdle(
          hasKeyOnDevice: true,
          history: [const ChatTurn(isUser: false, text: 'Key saved in your encrypted local vault. Ask anything (general fitness, habits, plans).', wasGuardrail: false), ..._historyFrom(state)],
        ),
      );
    }
  }

  Future<void> _onClear(AiClearKey e, Emitter<AiState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const AiError('Sign in to manage a key on this device'));
      return;
    }
    final err = await _secrets.clearGeminiKey();
    if (err != null) {
      emit(AiError(err, hasKeyOnDevice: _keyFlagFrom(state), history: _historyFrom(state)));
    } else {
      emit(
        const AiIdle(hasKeyOnDevice: false, history: <ChatTurn>[ChatTurn(isUser: false, text: 'Your Gemini key was removed from this device. Add it again to use the coach.', wasGuardrail: false)]),
      );
    }
  }

  Future<void> _onSend(AiSendUserMessage e, Emitter<AiState> emit) async {
    if (AppSession.instance.email == null) {
      emit(const AiUnauthenticated());
      return;
    }
    var history = <ChatTurn>[..._historyFrom(state)];
    final pre = AiSafety.checkUserMessage(e.text);
    if (pre is AiPreflightBlocked) {
      history = [...history, ChatTurn(isUser: true, text: e.text, wasGuardrail: false), ChatTurn(isUser: false, text: pre.reason, wasGuardrail: true)];
      emit(
        AiIdle(
          hasKeyOnDevice: _keyFlagFrom(state) || (await _secrets.readGeminiKey()) != null,
          history: history,
        ),
      );
      return;
    }
    final raw = await _secrets.readGeminiKey();
    if (raw == null || raw.trim().isEmpty) {
      emit(
        const AiError(
          'Add your Gemini API key above (Save key locally) before chatting.',
        ),
      );
      return;
    }
    history = [...history, ChatTurn(isUser: true, text: e.text, wasGuardrail: false)];
    emit(
      AiWorking(
        hasKeyOnDevice: true,
        history: history,
      ),
    );
    final client = GeminiFitnessClient.withUserKey(raw.trim());
    final email = AppSession.instance.email!;
    var profile = _profile.profileFor(email) ?? UserProfile(name: 'Friend', age: 25, goal: FitnessGoal.stayActive);
    final logs = _activity.listForCurrentUser();
    try {
      final out = await client.getAdvice(
        message: e.text,
        profile: profile,
        logs: logs,
      );
      final next = <ChatTurn>[...history, ChatTurn(isUser: false, text: out, wasGuardrail: false)];
      emit(
        AiIdle(
          hasKeyOnDevice: true,
          history: next,
        ),
      );
    } on GenerativeAIException catch (e) {
      emit(
        AiError('Gemini: ${e.message}. Check your key and try again later.', hasKeyOnDevice: true, history: history),
      );
    } catch (e) {
      emit(
        AiError('Something went wrong. Check your key and network. ($e)', hasKeyOnDevice: true, history: history),
      );
    }
  }

  Future<void> _onNew(AiNewChat e, Emitter<AiState> emit) async {
    final k = await _secrets.readGeminiKey();
    final has = k != null && k.trim().isNotEmpty;
    emit(AiIdle(hasKeyOnDevice: has, history: const <ChatTurn>[
      ChatTurn(isUser: false, text: 'New session. I’ll keep answers general and remind you: not medical advice.', wasGuardrail: false),
    ]),);
  }
}
