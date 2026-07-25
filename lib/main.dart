import 'package:coach_studio/app/routing/app_router.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:coach_studio/core/configs/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // These two Cubits have an app-wide lifecycle, meaning they stay alive at the app level (Singletons provided by get_it)
        // and are shared across tabs and internal pages (Add/Edit/Create).
        BlocProvider(create: (_) => sl<ExerciseCubit>()..loadExercises()),
        BlocProvider(create: (_) => sl<WorkoutProgramCubit>()..loadPrograms()),
      ],
      child: MaterialApp.router(
        title: 'Coach Studio',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
