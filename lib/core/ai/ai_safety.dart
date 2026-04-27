// Client-side pre-checks before calling the LLM. Complements the model [systemInstruction] and API safety.

/// Result of a local "guardrail" check on a user string.
sealed class AiPreflight {
  const AiPreflight();
}

/// The message is allowed to be sent to the model (API safety settings still apply).
class AiPreflightAllowed extends AiPreflight {
  const AiPreflightAllowed();
}

/// The message is blocked; [reason] is user-facing.
class AiPreflightBlocked extends AiPreflight {
  const AiPreflightBlocked(this.reason);
  final String reason;
}

/// Heuristic local filters for self-harm, hard medical claims, and "too extreme" dieting.
class AiSafety {
  AiSafety._();

  static const List<String> _emergencyKeywords = <String>[
    'suicid',
    'kill myself',
    'self-harm',
    'self harm',
    'emergency',
    'heart attack',
    'stroke',
    'not breathing',
    "can't breathe",
    'cannot breathe',
    'unable to breathe',
  ];

  static bool _containsAny(String t, List<String> ks) {
    final l = t.toLowerCase();
    for (final k in ks) {
      if (l.contains(k)) {
        return true;
      }
    }
    return false;
  }

  static final _ExtremeDietHeuristics _extremeDiet = _ExtremeDietHeuristics();
  static const List<String> _steroids = <String>['steroid', 'dnp', 'clenbuterol', 't3 ', 't4 '];

  /// Returns [AiPreflightBlocked] when the input should not be sent, even with a good API key.
  static AiPreflight checkUserMessage(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const AiPreflightBlocked('Write a short question so we can help.');
    }
    if (text.length > 2000) {
      return const AiPreflightBlocked('That message is too long — try a shorter question.');
    }
    if (_containsAny(text, _emergencyKeywords)) {
      return const AiPreflightBlocked(
        'This sounds like it could be urgent. Please contact a doctor or local emergency number — this app is not a substitute for medical help.',
      );
    }
    if (_extremeDiet.matches(text)) {
      return const AiPreflightBlocked(
        'We can’t help with that kind of very low intake or “crash” dieting. Ask for sustainable weekly habits or speak with a professional.',
      );
    }
    final l = text.toLowerCase();
    for (final s in _steroids) {
      if (l.contains(s)) {
        return const AiPreflightBlocked(
          'We don’t help with PEDs or performance drugs. We can only discuss general, legal fitness habits.',
        );
      }
    }
    return const AiPreflightAllowed();
  }
}

/// Catches a few "crash diet" and numeric calorie red flags in plain language.
class _ExtremeDietHeuristics {
  bool matches(String t) {
    // Under ~800 kcal "daily" in conversation is almost always disordered-adjacent for general apps.
    final cals = RegExp(r'(\d{3,4})\s*kc?al', caseSensitive: false);
    final m = cals.firstMatch(t);
    if (m != null) {
      final v = int.tryParse(m.group(1)!);
      if (v != null && v < 900) {
        // Only flag if clearly framed as daily (not a snack).
        if (t.toLowerCase().contains('day') || t.toLowerCase().contains('daily') || t.toLowerCase().contains('per day')) {
          return true;
        }
      }
    }
    if (t.toLowerCase().contains('water fast') && t.toLowerCase().contains('7')) {
      return true;
    }
    if (t.toLowerCase().contains('dry fast') || t.toLowerCase().contains('zero calorie') && t.toLowerCase().contains('weeks')) {
      return true;
    }
    return false;
  }
}
