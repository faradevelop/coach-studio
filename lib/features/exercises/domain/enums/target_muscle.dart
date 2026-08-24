enum TargetMuscle {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
  fullBody;

  String get label {
    switch (this) {
      case TargetMuscle.chest:
        return 'سینه';
      case TargetMuscle.back:
        return 'پشت';
      case TargetMuscle.shoulders:
        return 'سرشانه';
      case TargetMuscle.arms:
        return 'بازو';
      case TargetMuscle.legs:
        return 'پا';
      case TargetMuscle.core:
        return 'شکم و میان‌تنه';
      case TargetMuscle.fullBody:
        return 'کل بدن';
    }
  }
}
