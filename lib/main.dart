import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

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
    return MaterialApp(
      title: 'Coach Studio',
      theme: AppTheme.light,
      home: BlocProvider(
        create: (_) => sl<WorkoutProgramCubit>()..loadPrograms(),
        child: const WorkoutProgramListPage(),
      ),
    );
  }
}
