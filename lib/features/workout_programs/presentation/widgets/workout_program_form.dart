import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:flutter/material.dart';

class WorkoutProgramForm extends StatefulWidget {
  final WorkoutProgram? initialProgram;

  final bool isLoading;

  final Function(WorkoutProgram program) onSubmit;

  const WorkoutProgramForm({
    super.key,
    this.initialProgram,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<WorkoutProgramForm> createState() => _WorkoutProgramFormState();
}

class _WorkoutProgramFormState extends State<WorkoutProgramForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _daysController;
  late final TextEditingController _notesController;
  ProgramGoal? _goal;
  ProgramLevel? _level;

  @override
  void initState() {
    super.initState();
    final program = widget.initialProgram;
    _titleController = TextEditingController(text: program?.title ?? '');
    _daysController = TextEditingController(
      text: program?.daysPerWeek.toString() ?? '',
    );
    _notesController = TextEditingController(text: program?.notes ?? '');
    _goal = program?.goal;
    _level = program?.level;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _daysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final oldProgram = widget.initialProgram;

    final program = WorkoutProgram(
      id: oldProgram?.id ?? '',
      title: _titleController.text.trim(),
      goal: _goal!,
      level: _level!,
      daysPerWeek: int.parse(_daysController.text),
      notes: _notesController.text.trim(),
      isTemplate: oldProgram?.isTemplate ?? true,
    );

    widget.onSubmit(program);
  }

  @override
  Widget build(BuildContext context) {
    final oldProgram = widget.initialProgram;

    return Form(
      key: _formKey,

      child: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          TextFormField(
            controller: _titleController,

            decoration: const InputDecoration(labelText: 'Program Name'),

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<ProgramGoal>(
            initialValue: _goal,

            decoration: const InputDecoration(labelText: 'Goal'),

            items: ProgramGoal.values.map((goal) {
              return DropdownMenuItem(value: goal, child: Text(goal.name));
            }).toList(),

            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _goal = value;
                    });
                  },

            validator: (value) => value == null ? 'Required' : null,
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<ProgramLevel>(
            initialValue: _level,

            decoration: const InputDecoration(labelText: 'Level'),

            items: ProgramLevel.values.map((level) {
              return DropdownMenuItem(value: level, child: Text(level.name));
            }).toList(),

            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _level = value;
                    });
                  },

            validator: (value) => value == null ? 'Required' : null,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _daysController,

            keyboardType: TextInputType.number,

            decoration: const InputDecoration(labelText: 'Days Per Week'),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }

              if (int.tryParse(value) == null) {
                return 'Enter number';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,

            maxLines: 3,

            decoration: const InputDecoration(labelText: 'Notes'),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: widget.isLoading ? null : _submit,

            child: widget.isLoading
                ? const SizedBox(
                    height: 20,

                    width: 20,

                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(oldProgram == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }
}
