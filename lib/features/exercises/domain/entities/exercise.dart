import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';

class Exercise {
  final String id;
  final String name;
  final ExerciseType? type;
  final List<Muscle> targetMuscles;
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

  const Exercise({
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

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseType? type,
    List<Muscle>? targetMuscles,
    Difficulty? difficulty,
    Equipment? equipment,
    String? imageUrl,
    String? videoUrl,
    String? description,
    bool? isActive,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
