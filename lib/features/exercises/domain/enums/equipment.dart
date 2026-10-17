enum Equipment {
  barbell,
  dumbbell,
  machine,
  cable,
  bodyweight,
  other;

  String get label {
    switch (this) {
      case Equipment.barbell:
        return 'هالتر';
      case Equipment.dumbbell:
        return 'دمبل';
      case Equipment.machine:
        return 'دستگاه';
      case Equipment.cable:
        return 'کابل';
      case Equipment.bodyweight:
        return 'وزن بدن';
      case Equipment.other:
        return 'سایر';
    }
  }
}
