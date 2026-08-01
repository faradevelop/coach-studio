class ProgramExerciseItem {
  final String id;
  final String programExerciseId;
  final String exerciseId;
  final int order;
  final String reps;
  final String tempo;
  final String? description;

  const ProgramExerciseItem({
    required this.id,
    required this.programExerciseId,
    required this.exerciseId,
    required this.order,
    required this.reps,
    required this.tempo,
    this.description,
  });

  ProgramExerciseItem copyWith({
    String? id,
    String? programExerciseId,
    String? exerciseId,
    int? order,
    String? reps,
    String? tempo,
    String? description,
  }) {
    return ProgramExerciseItem(
      id: id ?? this.id,
      programExerciseId: programExerciseId ?? this.programExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      reps: reps ?? this.reps,
      tempo: tempo ?? this.tempo,
      description: description ?? this.description,
    );
  }
}
