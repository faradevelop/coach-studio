enum ProgramGoal {
  hypertrophy,
  strength,
  fatLoss,
  endurance,
  rehabilitation;

  String get label {
    return switch (this) {
      ProgramGoal.hypertrophy => 'هایپرتروفی',
      ProgramGoal.strength => 'قدرتی',
      ProgramGoal.fatLoss => 'چربی‌سوزی',
      ProgramGoal.endurance => 'استقامتی',
      ProgramGoal.rehabilitation => 'توان‌بخشی',
    };
  }
}
