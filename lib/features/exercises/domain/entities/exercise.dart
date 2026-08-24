import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/target_muscle.dart';

class Exercise {
  final String id;
  final String name;
  final TargetMuscle targetMuscle;
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
    TargetMuscle? targetMuscle,
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
      targetMuscle: targetMuscle ?? this.targetMuscle,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
