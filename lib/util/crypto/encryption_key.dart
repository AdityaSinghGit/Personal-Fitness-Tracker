// Key derivation for Hive AES (32 bytes) from email + password using a fixed in-app label.
// Not a password-storage substitute; used only to derive bytes for [HiveAesCipher].

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../security_peppers.dart';

/// Derives a 32-byte key suitable for [HiveAesCipher] from [email] and [password].
/// The same inputs always produce the same key, so the vault reopens after a fresh login in this tab.
List<int> deriveVaultKey({required String email, required String password}) {
  final input = utf8.encode('${SecurityPeppers.vaultKeyV1}:$email:$password');
  return sha256.convert(input).bytes;
}
