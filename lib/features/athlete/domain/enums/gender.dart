enum Gender {
  male,
  female;

  String get label => switch (this) {
    Gender.male => 'مرد',
    Gender.female => 'زن',
  };
}
