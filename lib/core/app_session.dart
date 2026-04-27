// In-memory session for the current user. Used to open encrypted Hive boxes; cleared on logout.
// A full page reload on web clears this, so the user must sign in again to unlock the encrypted vault.

/// Holds the active user email and derived 32-byte key for Hive [HiveAesCipher]. Never persisted.
class AppSession {
  AppSession._();
  static final AppSession instance = AppSession._();

  /// The signed-in user's email, or `null` if not authenticated in this tab.
  String? email;

  /// 32-byte key for the encrypted `vault` Hive box. Stays in memory only for this app session.
  List<int>? encryptionKeyBytes;

  /// Whether both email and a valid 32-byte key are present.
  bool get isAuthenticated => email != null && encryptionKeyBytes != null && encryptionKeyBytes!.length == 32;

  /// Binds a session after successful password verification. Replaces any prior session.
  void start({required String email, required List<int> encryptionKeyBytes}) {
    if (encryptionKeyBytes.length != 32) {
      throw ArgumentError('Encryption key must be 32 bytes');
    }
    this.email = email;
    this.encryptionKeyBytes = List<int>.from(encryptionKeyBytes);
  }

  /// Clears the in-memory session. Call on logout and before disposing sensitive state.
  void clear() {
    email = null;
    encryptionKeyBytes = null;
  }
}
