enum TrainingSystem {
  normal,
  superSet;

  String get label {
    return switch (this) {
      TrainingSystem.normal => 'معمولی',
      TrainingSystem.superSet => 'سوپرست',
    };
  }
}
