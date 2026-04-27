// Text validators for sign-up, sign-in, and profile/activity fields.

import 'string_extensions.dart';

/// User-facing error messages, if any, or `null` when the value is valid.
class Validators {
  Validators._();

  static const int minPasswordLength = 8;
  static const int minNameLength = 1;
  static const int minActivityTitleLength = 2;
  static const int maxMessageLength = 2000;
  static const int maxApiKeyLength = 512;

  static String? email(String? v) {
    if (v.isBlank) return 'Enter an email';
    final trimmed = v!.trim();
    if (!trimmed.contains('@') || trimmed.length < 5) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < minPasswordLength) return 'Use at least $minPasswordLength characters';
    if (v.length > 128) return 'Password is too long';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a name';
    if (v.trim().length < minNameLength) return 'Name is too short';
    if (v.length > 80) return 'Name is too long';
    return null;
  }

  static String? age(String? v) {
    if (v.isBlank) return 'Enter an age';
    final n = int.tryParse(v!.trim());
    if (n == null) return 'Enter a whole number';
    if (n < 13 || n > 100) return 'Use an age between 13 and 100 (general fitness use)';
    return null;
  }

  static String? activityTitle(String? v) {
    if (v == null || v.trim().length < minActivityTitleLength) {
      return 'Add a bit more detail (at least $minActivityTitleLength characters)';
    }
    if (v.length > 200) return 'Description is too long';
    return null;
  }

  static String? activityMinutes(String? v) {
    if (v.isBlank) return 'Enter duration in minutes';
    final n = int.tryParse(v!.trim());
    if (n == null) return 'Enter a whole number of minutes';
    if (n < 1) return 'Use at least 1 minute';
    if (n > 24 * 60) return 'That is longer than a day — check the value';
    return null;
  }

  static String? userMessageToAi(String? v) {
    if (v.isBlank) return 'Write a message to get a response';
    if (v!.trim().length < 2) return 'A little more context helps';
    if (v.length > maxMessageLength) {
      return 'Message is too long (max $maxMessageLength characters)';
    }
    return null;
  }

  static String? optionalGeminiKey(String? v) {
    if (v == null) return 'Paste your API key to continue';
    if (v.trim().isEmpty) return 'Paste your API key to continue';
    if (v.trim().length < 8) return 'Key looks too short';
    if (v.length > maxApiKeyLength) return 'Key is too long to store locally';
    return null;
  }
}
