// One logged workout or activity with duration and subjective "feel" (1–5).

/// A single local activity log entry.
class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.minutes,
    required this.feel1to5,
    required this.loggedAt,
  });

  final String id;
  final String userEmail;
  final String title;
  final int minutes;
  final int feel1to5;
  final DateTime loggedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'title': title,
    'minutes': minutes,
    'feel1to5': feel1to5,
    'loggedAt': loggedAt.toIso8601String(),
  };

  /// Parses a map from storage; provides minimal validation.
  factory ActivityLog.fromMap(Map<dynamic, dynamic> map) {
    return ActivityLog(
      id: '${map['id']}',
      userEmail: '${map['userEmail']}',
      title: '${map['title']}',
      minutes: (map['minutes'] is int) ? map['minutes'] as int : int.parse('${map['minutes'] ?? 0}'),
      feel1to5: (map['feel1to5'] is int) ? map['feel1to5'] as int : int.parse('${map['feel1to5'] ?? 3}'),
      loggedAt: DateTime.tryParse('${map['loggedAt']}') ?? DateTime.now().toUtc(),
    );
  }
}
