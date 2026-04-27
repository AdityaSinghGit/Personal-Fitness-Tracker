// User-selectable long-term goal used in profile and AI context.

/// Coarse fitness goals for onboarding and LLM context.
enum FitnessGoal {
  loseWeight,
  buildStrength,
  stayActive,
}

/// Maps API / storage string keys to [FitnessGoal].
extension FitnessGoalCodec on FitnessGoal {
  String get key => switch (this) {
    FitnessGoal.loseWeight => 'lose_weight',
    FitnessGoal.buildStrength => 'build_strength',
    FitnessGoal.stayActive => 'stay_active',
  };

  String get shortLabel => switch (this) {
    FitnessGoal.loseWeight => 'Lose weight',
    FitnessGoal.buildStrength => 'Build strength',
    FitnessGoal.stayActive => 'Stay active',
  };
}

/// Parses a stored [key] or returns [FitnessGoal.stayActive] as default.
FitnessGoal fitnessGoalFromKey(String? key) {
  return switch (key) {
    'lose_weight' => FitnessGoal.loseWeight,
    'build_strength' => FitnessGoal.buildStrength,
    'stay_active' => FitnessGoal.stayActive,
    _ => FitnessGoal.stayActive,
  };
}
