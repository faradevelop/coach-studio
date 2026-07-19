import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory ExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ExerciseModel(
      id: doc.id,
      name: data['name'] ?? '',
      targetMuscle: data['targetMuscle'] ?? '',
      difficulty: data['difficulty'] ?? '',
      equipment: data['equipment'] ?? '',

      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],

      description: data['description'],
      instructions: data['instructions'],
      mistakes: data['mistakes'],

      isActive: data['isActive'] ?? true,

      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
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

      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
