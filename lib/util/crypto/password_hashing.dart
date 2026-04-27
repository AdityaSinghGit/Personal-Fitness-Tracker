// Password storage helpers: random salt + SHA-256. Suitable for this offline, non-server demo only.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../security_peppers.dart';

/// Produces a new random salt and a hex-encoded password hash to persist locally.
({String salt, String passwordHash}) hashPasswordForStorage(String password) {
  final salt = _randomSalt(24);
  return (salt: salt, passwordHash: _hashWithSalt(salt, password));
}

/// Returns `true` if the [password] matches a previously stored [salt] + [storedHash] pair.
bool verifyPassword({required String password, required String salt, required String storedHash}) {
  return _hashWithSalt(salt, password) == storedHash;
}

String _hashWithSalt(String salt, String password) {
  final data = utf8.encode('${SecurityPeppers.passwordV1}:$salt:$password');
  return sha256.convert(data).toString();
}

String _randomSalt(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final r = Random.secure();
  return List<String>.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
}
