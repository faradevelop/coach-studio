import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _program = WorkoutProgram(
  id: 'p1',
  title: 'Push',
  goal: ProgramGoal.strength,
  level: ProgramLevel.beginner,
  daysPerWeek: 3,
  isTemplate: true,
);

class _FakeRepo implements WorkoutProgramRepository {
  Object? mutationError;
  bool failList = false;
  int listCalls = 0;

  @override
  Future<List<WorkoutProgram>> getPrograms({
    WorkoutProgramFilter filter = const WorkoutProgramFilter(),
  }) async {
    listCalls++;
    if (failList) throw const NetworkException('offline');
    return [_program];
  }

  Future<T> _mutate<T>(T value) async {
    if (mutationError != null) throw mutationError!;
    return value;
  }

  @override
  Future<WorkoutProgram> addDay(String programId) => _mutate(_program);
  @override
  Future<void> deleteDay(String programId, int day) => _mutate<void>(null);
  @override
  Future<void> reorderDay(String programId, int day, int order) =>
      _mutate<void>(null);
  @override
  Future<void> deleteProgram(String id) => _mutate<void>(null);
  @override
  Future<void> updateProgram(WorkoutProgram program) => _mutate<void>(null);
  @override
  Future<void> duplicateProgram(String id, String title) => _mutate<void>(null);
  @override
  Future<WorkoutProgram> addProgram(WorkoutProgram program) =>
      _mutate(_program);
}

void main() {
  late _FakeRepo repo;
  late WorkoutProgramCubit cubit;

  setUp(() async {
    repo = _FakeRepo();
    cubit = WorkoutProgramCubit(repository: repo, logger: FakeLogger());
    await cubit.loadPrograms();
  });

  tearDown(() => cubit.close());

  test('initial load emits Loaded', () {
    expect(cubit.state, isA<WorkoutProgramLoaded>());
  });

  test(
    'failed addDay keeps the list and clears isSubmitting (no Error state)',
    () async {
      repo.mutationError = const NetworkException('offline');
      final callsBefore = repo.listCalls;

      expect(await cubit.addDay('p1'), isFalse);

      final state = cubit.state;
      expect(state, isA<WorkoutProgramLoaded>());
      expect((state as WorkoutProgramLoaded).isSubmitting, isFalse);
      expect(state.programs, hasLength(1));
      expect(repo.listCalls, callsBefore); // no refresh after a failure
    },
  );

  test('failed deleteProgram leaves the list untouched', () async {
    repo.mutationError = const ValidationException('assigned');
    expect(await cubit.deleteProgram('p1'), isFalse);
    expect(cubit.state, isA<WorkoutProgramLoaded>());
  });

  test(
    'successful mutation with a failing refresh still returns true',
    () async {
      repo.failList = true;
      expect(await cubit.deleteProgram('p1'), isTrue);
      expect(cubit.state, isA<WorkoutProgramLoaded>());
    },
  );

  test('second day operation is refused while one is in flight', () async {
    final first = cubit.addDay('p1');
    expect(await cubit.addDay('p1'), isFalse);
    expect(await first, isTrue);
  });

  test('a failing initial load emits Error', () async {
    repo.failList = true;
    await cubit.loadPrograms();
    expect(cubit.state, isA<WorkoutProgramError>());
  });
}
