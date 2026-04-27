// User profile (name, age, goal) stored per email in a plain Hive box.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';

import '../models/user_profile.dart';

class ProfileRepository {
  const ProfileRepository();

  Box<Map<dynamic, dynamic>> get _box => Hive.box<Map<dynamic, dynamic>>(kUserProfilesBox);

  /// Returns the default profile for empty storage.
  UserProfile? profileFor(String email) {
    final m = _box.get(email.trim().toLowerCase());
    if (m == null) return null;
    return UserProfile.fromMap(m);
  }

  /// Replaces the stored map for the given [email] with [p].
  Future<void> saveProfileForEmail(String email, UserProfile p) async {
    final e = email.trim().toLowerCase();
    await _box.put(e, p.toMap());
  }
}
