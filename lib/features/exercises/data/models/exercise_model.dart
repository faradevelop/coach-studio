import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String targetMuscle;
  final String difficulty;
  final String equipment;
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
    required this.targetMuscle,
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
    String? targetMuscle,
    String? difficulty,
    String? equipment,
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
      targetMuscle: targetMuscle ?? this.targetMuscle,
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
      targetMuscle: entity.targetMuscle,
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
      targetMuscle: targetMuscle,
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
      targetMuscle: json['targetMuscle'] as String,
      difficulty: json['difficulty'] as String,
      equipment: json['equipment'] as String,
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
      'targetMuscle': targetMuscle,
      'difficulty': difficulty,
      'equipment': equipment,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'description': description,
      'instructions': instructions,
      'mistakes': mistakes,
      'isActive': isActive,
    };
  }
}
