// In-app string labels to separate KDFs (vault vs password hash). Not secret by themselves; they bind domains.

/// Static application labels for key derivation. Changing these will invalidate local vaults.
class SecurityPeppers {
  SecurityPeppers._();
  static const String vaultKeyV1 = 'pft_vault_kdf_v1';
  static const String passwordV1 = 'pft_pwd_v1';
}
