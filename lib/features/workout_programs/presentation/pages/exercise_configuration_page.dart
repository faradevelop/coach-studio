import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

class ExerciseConfigurationPage extends StatefulWidget {
  final String programId;
  final Exercise exercise;

  const ExerciseConfigurationPage({
    super.key,
    required this.programId,
    required this.exercise,
  });

  @override
  State<ExerciseConfigurationPage> createState() =>
      _ExerciseConfigurationPageState();
}

class _ExerciseConfigurationPageState extends State<ExerciseConfigurationPage> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController(text: '4');
  final _repsController = TextEditingController(text: '10-12');
  final _tempoController = TextEditingController(text: '3-1-1');
  final _restController = TextEditingController(text: '90');

  int _day = 1;
  int _order = 1;

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _tempoController.dispose();
    _restController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              Text(
                widget.exercise.name,

                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _setsController,

                decoration: const InputDecoration(labelText: 'Sets'),
              ),

              TextFormField(
                controller: _repsController,

                decoration: const InputDecoration(labelText: 'Reps'),
              ),

              TextFormField(
                controller: _tempoController,

                decoration: const InputDecoration(labelText: 'Tempo'),
              ),

              TextFormField(
                controller: _restController,

                decoration: const InputDecoration(labelText: 'Rest'),
              ),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: () {},

                child: const Text('Save Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
