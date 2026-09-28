import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the currently APPLIED [ExerciseFilter]. Temporary in-progress
/// selections while a filter's bottom sheet is open live in that sheet's
/// own local widget state (see [MultiSelectBottomSheet]) and only reach
/// this Cubit through the apply* methods — so Cancel never touches applied
/// state.
class ExerciseFilterCubit extends Cubit<ExerciseFilter> {
  ExerciseFilterCubit() : super(const ExerciseFilter());

  void applyMuscles(List<Muscle> muscles) =>
      emit(state.copyWith(muscles: muscles));

  void applyEquipment(List<Equipment> equipment) =>
      emit(state.copyWith(equipment: equipment));

  void applyDifficulty(Difficulty? difficulty) => emit(
    state.copyWith(difficulty: difficulty, clearDifficulty: difficulty == null),
  );

  void applyType(ExerciseType? type) =>
      emit(state.copyWith(type: type, clearType: type == null));

  void clearMuscles() => emit(state.copyWith(muscles: const []));
  void clearEquipment() => emit(state.copyWith(equipment: const []));
  void clearDifficulty() => emit(state.copyWith(clearDifficulty: true));
  void clearType() => emit(state.copyWith(clearType: true));
  void clearAll() => emit(const ExerciseFilter());
}
