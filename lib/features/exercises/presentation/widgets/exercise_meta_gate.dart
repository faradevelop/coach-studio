import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ExerciseMetaGate extends StatefulWidget {
  final Widget child;
  const ExerciseMetaGate({super.key, required this.child});
  @override
  State<ExerciseMetaGate> createState() => _ExerciseMetaGateState();
}

class _ExerciseMetaGateState extends State<ExerciseMetaGate> {
  late Future<bool> _meta;

  @override
  void initState() {
    super.initState();
    _meta = context.read<ExerciseCubit>().ensureMetaLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _meta,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.orange,
              size: 40,
            ),
          );
        }
        if (snap.data != true) {
          return AppErrorState(
            onRetry: () => setState(
              () => _meta = context.read<ExerciseCubit>().ensureMetaLoaded(),
            ),
          );
        }
        return widget.child;
      },
    );
  }
}
