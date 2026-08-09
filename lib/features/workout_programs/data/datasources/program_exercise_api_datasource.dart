import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_item_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

class ProgramExerciseApiDatasource {
  final ApiClient client;

  ProgramExerciseApiDatasource({required this.client});

  /// Calls GET /workout-programs/{workoutProgramId}/program-exercises,
  /// which already returns the exercise-joined shape
  /// (ProgramExerciseDetailResource) — no separate per-item exercise
  /// lookup is needed client-side, unlike the old Firestore flow.
  Future<List<ProgramExerciseDetails>> getProgramExerciseDetails(
    String workoutProgramId,
  ) async {
    final data =
        await client.get(
              '/workout-programs/$workoutProgramId/program-exercises',
            )
            as List<dynamic>;

    return data
        .map((json) => _detailsFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProgramExerciseModel> createProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    final data =
        await client.post('/program-exercises', exercise.toRequestJson())
            as Map<String, dynamic>;
    return ProgramExerciseModel.fromJson(data);
  }

  Future<ProgramExerciseModel> updateProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    final data =
        await client.put(
              '/program-exercises/${exercise.id}',
              exercise.toRequestJson(),
            )
            as Map<String, dynamic>;
    return ProgramExerciseModel.fromJson(data);
  }

  Future<void> deleteProgramExercise(String id) async {
    await client.delete('/program-exercises/$id');
  }

  Future<void> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    await client.patch('/program-exercises/$exerciseId/reorder', {
      'order': targetOrder,
    });
  }

  ProgramExerciseDetails _detailsFromJson(Map<String, dynamic> json) {
    final programExercise = ProgramExerciseModel.fromJson(
      json['programExercise'] as Map<String, dynamic>,
    ).toEntity();

    final items = (json['items'] as List<dynamic>).map((raw) {
      final map = raw as Map<String, dynamic>;
      final item = ProgramExerciseItemModel.fromJson(
        map['item'] as Map<String, dynamic>,
      ).toEntity();
      final exercise = ExerciseModel.fromJson(
        map['exercise'] as Map<String, dynamic>,
      ).toEntity();

      return ProgramExerciseItemDetails(item: item, exercise: exercise);
    }).toList();

    return ProgramExerciseDetails(
      programExercise: programExercise,
      items: items,
    );
  }
}
