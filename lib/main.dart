import 'package:coach_studio/app/routing/app_router.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:coach_studio/core/configs/firebase_options.dart';

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
    return MaterialApp.router(
      title: 'Coach Studio',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
