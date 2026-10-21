enum Gender {
  male,
  female,
  other;

  String get label => switch (this) {
    Gender.male => 'مرد',
    Gender.female => 'زن',
    Gender.other => 'سایر',
  };
}
