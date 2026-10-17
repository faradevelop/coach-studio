enum ProgramLevel {
  beginner,
  intermediate,
  advanced;

  String get label {
    return switch (this) {
      ProgramLevel.beginner => 'مبتدی',
      ProgramLevel.intermediate => 'متوسط',
      ProgramLevel.advanced => 'پیشرفته',
    };
  }
}
