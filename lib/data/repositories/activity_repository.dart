// Append-only list of [ActivityLog] per user, stored as JSON-like maps in Hive.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:personal_fitness_tracker/core/app_session.dart';
import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';

import '../models/activity_log.dart';

const String _kActivityListKey = 'list';

class ActivityRepository {
  const ActivityRepository();
  static const _uuid = Uuid();

  Box<Map<dynamic, dynamic>> get _box => Hive.box<Map<dynamic, dynamic>>(kActivityStoreBox);

  /// All entries for the active user, most recent first.
  List<ActivityLog> listForCurrentUser() {
    final email = AppSession.instance.email;
    if (email == null) return const [];
    final data = _box.get(email);
    if (data is! Map) return const [];
    final list = (data[_kActivityListKey] as List<dynamic>?) ?? const <dynamic>[];
    final logs = <ActivityLog>[];
    for (final m in list) {
      if (m is! Map) continue;
      try {
        logs.add(ActivityLog.fromMap(m));
      } catch (_) {
        // Corrupt single row: skip; keeps list view usable
      }
    }
    logs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return logs;
  }

  /// Adds a new [ActivityLog] and persists it, or `null` if the session is not active.
  Future<ActivityLog?> add({
    required String title,
    required int minutes,
    required int feel1to5,
  }) async {
    final email = AppSession.instance.email;
    if (email == null) return null;
    final log = ActivityLog(
      id: _uuid.v4(),
      userEmail: email,
      title: title,
      minutes: minutes,
      feel1to5: feel1to5,
      loggedAt: DateTime.now().toUtc(),
    );
    final list = listForCurrentUser();
    final combined = <ActivityLog>[log, ...list];
    await _box.put(
      email,
      {
        _kActivityListKey: combined.map((a) => a.toMap()).toList(),
      },
    );
    return log;
  }

  /// Clears every activity for the [email] (used when deleting a local user account, if added later).
  Future<void> clearFor(String email) async {
    await _box.delete(email.trim().toLowerCase());
  }
}
