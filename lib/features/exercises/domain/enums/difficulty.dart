enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'مبتدی';
      case Difficulty.intermediate:
        return 'متوسط';
      case Difficulty.advanced:
        return 'پیشرفته';
    }
  }
}
