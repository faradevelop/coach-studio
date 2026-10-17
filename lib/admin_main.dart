import 'dart:async';

import 'package:coach_studio/admin/admin_router.dart';
import 'package:coach_studio/core/bootstrap/global_error_handling.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:coach_studio/core/widgets/responsive/app_scroll_behavior.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Run:   flutter run -d chrome -t lib/admin_main.dart
/// Build: flutter build web -t lib/admin_main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGlobalErrorHandling();

  await initDependencies(
    allowedRole: UserRole.admin,
    navigatorKey: AdminRouter.navigatorKey,
  );
  await sl<TokenStorage>().init();
  unawaited(sl<AuthCubit>().restoreSession());

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  static const double _maxWidth = 1400;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<ExerciseCubit>()),
        BlocProvider(create: (_) => sl<CoachCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<CoachCubit>().load();
            final exercises = context.read<ExerciseCubit>();
            if (exercises.state is ExerciseInitial ||
                exercises.state is ExerciseError) {
              exercises.loadExercises();
            }
          }
          if (state is AuthUnauthenticated) {
            context.read<CoachCubit>().reset();
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'Coach Studio Admin',
          theme: AppTheme.light,
          routerConfig: AdminRouter.router,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.bgColors,
                  stops: AppColors.bgStops,
                ),
              ),
              child: MaxWidthBox(
                maxWidth: _maxWidth,
                expandHeight: true,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
