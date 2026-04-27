// App-wide non-sensitive settings: last used email for form hints only.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';

class SettingsRepository {
  const SettingsRepository();

  Box<dynamic> get _box => Hive.box<dynamic>(kAppSettingsBox);

  /// Persists a hint (not a credential) for the sign-in email field.
  Future<void> setLastEmailHint(String? email) async {
    if (email == null || email.isEmpty) {
      await _box.delete(kSettingsKeyLastEmail);
    } else {
      await _box.put(kSettingsKeyLastEmail, email.trim().toLowerCase());
    }
  }

  String? get lastEmailHint {
    return _box.get(kSettingsKeyLastEmail) as String?;
  }
}
