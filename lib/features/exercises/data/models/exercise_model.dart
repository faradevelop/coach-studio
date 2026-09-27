import 'package:coach_studio/features/exercises/data/models/muscle_model.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';

class ExerciseModel {
  final String id;
  final String name;
  final ExerciseType? type;
  final List<MuscleModel> targetMuscles;
  final Difficulty difficulty;
  final Equipment equipment;
  final String? imageUrl;
  final String? videoUrl;
  final String? description;
  final String? instructions;
  final String? mistakes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.type,
    this.targetMuscles = const [],
    required this.difficulty,
    required this.equipment,
    this.imageUrl,
    this.videoUrl,
    this.description,
    this.instructions,
    this.mistakes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  ExerciseModel copyWith({
    String? name,
    ExerciseType? type,
    List<MuscleModel>? targetMuscles,
    Difficulty? difficulty,
    Equipment? equipment,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? instructions,
    String? mistakes,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ExerciseModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      mistakes: mistakes ?? this.mistakes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory ExerciseModel.fromEntity(Exercise entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      targetMuscles: entity.targetMuscles
          .map((muscle) => MuscleModel.fromEntity(muscle))
          .toList(),
      difficulty: entity.difficulty,
      equipment: entity.equipment,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      description: entity.description,
      instructions: entity.instructions,
      mistakes: entity.mistakes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Exercise toEntity() {
    return Exercise(
      id: id,
      name: name,
      type: type,
      targetMuscles: targetMuscles.map((muscle) => muscle.toEntity()).toList(),
      difficulty: difficulty,
      equipment: equipment,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      description: description,
      instructions: instructions,
      mistakes: mistakes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] != null
          ? ExerciseType.values.byName(json['type'] as String)
          : null,
      targetMuscles: (json['targetMuscles'] as List<dynamic>? ?? [])
          .map((muscle) => MuscleModel.fromJson(muscle as Map<String, dynamic>))
          .toList(),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      equipment: Equipment.values.byName(json['equipment'] as String),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      mistakes: json['mistakes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'type': type?.name,
      'targetMuscles': targetMuscles.map((muscle) => muscle.slug).toList(),
      'difficulty': difficulty.name,
      'equipment': equipment.name,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'description': description,
      'instructions': instructions,
      'mistakes': mistakes,
      'isActive': isActive,
    };
  }
}
