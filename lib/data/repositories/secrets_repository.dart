// Encrypted Hive box (Hive AES) for the user-provided Gemini key. The cipher key is derived at login.
// Box file name is namespaced by a hash of the email to avoid key collisions if accounts switch.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';

import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';

/// Manages a small encrypted [Box] for the API key, opened with [AppSession] key material.
class SecretsRepository {
  SecretsRepository();

  Box<dynamic>? _openVault;

  /// A stable, filesystem-safe name per email for the encrypted vault box.
  @visibleForTesting
  String vaultNameFor(String email) {
    final d = sha256.convert(utf8.encode('pft_vault_id:$email'));
    return 'pft_v_${d.toString().substring(0, 24)}';
  }

  /// Closes the current vault, if any. Call before logout or re-login.
  Future<void> closeVault() async {
    if (_openVault == null) return;
    if (_openVault!.isOpen) {
      await _openVault!.close();
    }
    _openVault = null;
  }

  /// Returns the stored Gemini key, or `null` if not set. Opens the vault for the session email.
  Future<String?> readGeminiKey() async {
    final box = await _ensureBox();
    if (box == null) return null;
    return box.get(kVaultKeyGemini) as String?;
  }

  /// Persists the trimmed [apiKey] in the session vault, or `null` on failure.
  Future<String?> writeGeminiKey(String apiKey) async {
    final box = await _ensureBox();
    if (box == null) {
      return 'Not signed in — your API key is not stored until you sign in with a valid session.';
    }
    await box.put(kVaultKeyGemini, apiKey.trim());
    return null;
  }

  /// Clears the Gemini key in the current vault, if open.
  Future<String?> clearGeminiKey() async {
    final box = await _ensureBox();
    if (box == null) return 'Session is not active';
    await box.delete(kVaultKeyGemini);
    return null;
  }

  /// Opens the encrypted [Box] for [AppSession] using the 32-byte session key.
  Future<Box<dynamic>?> _ensureBox() async {
    final s = AppSession.instance;
    if (!s.isAuthenticated) return null;
    if (_openVault != null && _openVault!.isOpen) {
      return _openVault;
    }
    final keyBytes = s.encryptionKeyBytes;
    if (keyBytes == null) return null;
    final name = vaultNameFor(s.email!);
    _openVault = await Hive.openBox<dynamic>(
      name,
      encryptionCipher: HiveAesCipher(keyBytes),
    );
    return _openVault;
  }
}
