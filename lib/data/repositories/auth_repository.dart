// Email + password sign-up and sign-in backed by a plain Hive box. Passwords are salted hashes only.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';
import 'package:personal_fitness_tracker/data/models/fitness_goal.dart';
import 'package:personal_fitness_tracker/data/models/user_profile.dart';
import 'package:personal_fitness_tracker/util/crypto/encryption_key.dart';
import 'package:personal_fitness_tracker/util/crypto/password_hashing.dart';
import 'profile_repository.dart';
import 'settings_repository.dart';

/// Local authentication with no third-party services.
class AuthRepository {
  AuthRepository({
    required ProfileRepository profileRepository,
    required SettingsRepository settingsRepository,
  }) : _profileRepository = profileRepository,
       _settingsRepository = settingsRepository;

  final ProfileRepository _profileRepository;
  final SettingsRepository _settingsRepository;

  Box<Map<dynamic, dynamic>> get _box => Hive.box<Map<dynamic, dynamic>>(kAuthUsersBox);

  /// Registers a new user and seeds a default [UserProfile] if the email is not taken.
  /// Returns a human-readable error, or `null` on success.
  Future<String?> signUp({required String email, required String password, required String name, required int age, required FitnessGoal goal}) async {
    final e = email.trim().toLowerCase();
    if (_box.containsKey(e)) {
      return 'That email is already registered';
    }
    final hashed = hashPasswordForStorage(password);
    await _box.put(e, {
      'passwordHash': hashed.passwordHash,
      'salt': hashed.salt,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    final profile = UserProfile(name: name, age: age, goal: goal);
    await _profileRepository.saveProfileForEmail(e, profile);
    await _settingsRepository.setLastEmailHint(e);
    _bindSession(e, password);
    return null;
  }

  /// Verifies email/password, starts [AppSession], and refreshes the email hint.
  /// Returns an error string on failure, or `null` on success.
  Future<String?> signIn({required String email, required String password}) async {
    final e = email.trim().toLowerCase();
    final data = _box.get(e);
    if (data == null) {
      return 'No account for that email';
    }
    final ok = verifyPassword(
      password: password,
      salt: data['salt'] as String,
      storedHash: data['passwordHash'] as String,
    );
    if (!ok) {
      return 'Password does not match our records on this device';
    }
    await _settingsRepository.setLastEmailHint(e);
    _bindSession(e, password);
    return null;
  }

  void _bindSession(String email, String password) {
    final key = deriveVaultKey(email: email, password: password);
    AppSession.instance.start(email: email, encryptionKeyBytes: key);
  }
}
