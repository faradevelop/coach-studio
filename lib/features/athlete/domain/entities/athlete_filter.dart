enum AthleteStatus {
  active,
  archived,
  all;

  String get label => switch (this) {
    AthleteStatus.active => 'فعال',
    AthleteStatus.archived => 'بایگانی‌شده',
    AthleteStatus.all => 'همه',
  };
}

enum AthleteOrder {
  nameAsc,
  nameDesc,
  newest,
  oldest;

  String get label => switch (this) {
    AthleteOrder.nameAsc => 'نام (الف تا ی)',
    AthleteOrder.nameDesc => 'نام (ی تا الف)',
    AthleteOrder.newest => 'جدیدترین',
    AthleteOrder.oldest => 'قدیمی‌ترین',
  };

  /// Backend `sort` value.
  String get sort => switch (this) {
    AthleteOrder.nameAsc || AthleteOrder.nameDesc => 'name',
    AthleteOrder.newest || AthleteOrder.oldest => 'createdAt',
  };

  /// Backend `direction` value.
  String get direction => switch (this) {
    AthleteOrder.nameAsc || AthleteOrder.oldest => 'asc',
    AthleteOrder.nameDesc || AthleteOrder.newest => 'desc',
  };
}

class AthleteFilter {
  final String search;
  final AthleteStatus status;
  final bool? hasProgram;
  final AthleteOrder order;

  const AthleteFilter({
    this.search = '',
    this.status = AthleteStatus.active,
    this.hasProgram,
    this.order = AthleteOrder.nameAsc,
  });

  bool get isDefault =>
      search.isEmpty &&
      status == AthleteStatus.active &&
      hasProgram == null &&
      order == AthleteOrder.nameAsc;

  AthleteFilter copyWith({
    String? search,
    AthleteStatus? status,
    bool? hasProgram,
    AthleteOrder? order,
    bool clearHasProgram = false,
  }) => AthleteFilter(
    search: search ?? this.search,
    status: status ?? this.status,
    hasProgram: clearHasProgram ? null : (hasProgram ?? this.hasProgram),
    order: order ?? this.order,
  );
}
