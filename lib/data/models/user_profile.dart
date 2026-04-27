// Editable user profile: display name, age, and high-level goal.

import 'fitness_goal.dart';

/// Local profile for the signed-in user.
class UserProfile {
  const UserProfile({required this.name, required this.age, required this.goal});

  final String name;
  final int age;
  final FitnessGoal goal;

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'goal': goal.key,
  };

  /// Rebuilds a profile from Hive [map] values, with safe fallbacks.
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      name: (map['name'] as String?)?.trim().isNotEmpty == true ? map['name'] as String : 'Athlete',
      age: (map['age'] is int) ? map['age'] as int : int.tryParse('${map['age']}') ?? 25,
      goal: fitnessGoalFromKey(map['goal'] as String?),
    );
  }
}
