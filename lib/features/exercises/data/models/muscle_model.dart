import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';

class MuscleModel {
  final String id;
  final String name;
  final String slug;

  const MuscleModel({required this.id, required this.name, required this.slug});

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  Muscle toEntity() => Muscle(id: id, name: name, slug: slug);

  factory MuscleModel.fromEntity(Muscle entity) {
    return MuscleModel(id: entity.id, name: entity.name, slug: entity.slug);
  }
}
