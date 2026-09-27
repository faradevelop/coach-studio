enum ExerciseType {
  strength,
  cardio,
  stretching,
  mobility;

  String get label {
    return switch (this) {
      ExerciseType.strength => 'قدرتی',
      ExerciseType.cardio => 'هوازی',
      ExerciseType.stretching => 'کششی',
      ExerciseType.mobility => 'موبیلیتی',
    };
  }
}
