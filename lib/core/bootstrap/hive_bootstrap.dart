// One-time Flutter + Hive initialization for the app. Safe to call from main() before runApp.
import 'package:hive_flutter/hive_flutter.dart';

const String kAuthUsersBox = 'auth_users';
const String kUserProfilesBox = 'user_profiles';
const String kActivityStoreBox = 'activity_store';
const String kAppSettingsBox = 'app_settings';

/// [SecretsRepository] only — key id inside the encrypted vault box.
const String kVaultKeyGemini = 'geminiApiKey';
const String kSettingsKeyLastEmail = 'lastEmailHint';

/// Initializes local storage. On web, Hive uses IndexedDB; on other platforms, the app support directory.
Future<void> initLocalStorage() async {
  await Hive.initFlutter();
  // Open unencrypted boxes used across the app.
  await Future.wait<void>([
    Hive.openBox<Map<dynamic, dynamic>>(kAuthUsersBox),
    Hive.openBox<Map<dynamic, dynamic>>(kUserProfilesBox),
    Hive.openBox<Map<dynamic, dynamic>>(kActivityStoreBox),
    Hive.openBox<dynamic>(kAppSettingsBox),
  ]);
}
