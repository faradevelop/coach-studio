import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

class Exercise {
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

  const Exercise({
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

  Exercise copyWith({
    String? id,
    String? name,
    String? targetMuscle,
    String? difficulty,
    String? equipment,
    String? imageUrl,
    String? videoUrl,
    String? description,
    bool? isActive,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Exercise.fromModel(ExerciseModel model) {
    return Exercise(
      id: model.id,
      name: model.name,
      targetMuscle: model.targetMuscle,
      difficulty: model.difficulty,
      equipment: model.equipment,
      imageUrl: model.imageUrl,
      videoUrl: model.videoUrl,
      description: model.description,
      instructions: model.instructions,
      mistakes: model.mistakes,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  ExerciseModel toModel() {
    return ExerciseModel(
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
}
