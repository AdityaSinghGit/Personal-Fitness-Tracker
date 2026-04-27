// Small string helpers to keep forms readable.

/// Extensions on [String?] for blank checks used by validators and UI.
extension NullableStringX on String? {
  /// True if null, empty, or only whitespace.
  bool get isBlank {
    if (this == null) return true;
    return this!.trim().isEmpty;
  }
}
