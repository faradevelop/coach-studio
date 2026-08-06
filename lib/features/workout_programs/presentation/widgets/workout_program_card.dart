import 'dart:ui';

import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WorkoutProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  //final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const WorkoutProgramCard({
    super.key,
    required this.program,
    //required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        program.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                          height: 1.25,
                        ),
                      ),
                    ),

                    MiniButton(
                      color: Colors.red.withValues(alpha: 0.38),
                      icon: FaIcon(
                        FontAwesomeIcons.trash,
                        size: 12,
                        color: const Color.fromARGB(255, 186, 10, 10),
                      ),
                      onPressed: onDelete,
                    ),
                    // PopupMenuButton<String>(
                    //   padding: EdgeInsets.zero,
                    //   iconSize: 20,
                    //   color: const Color(0xFFFFF8F0),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   onSelected: (value) {
                    //     switch (value) {
                    //       case 'edit':
                    //         onEdit.call();
                    //         // context.pushNamed(
                    //         //   AppRouteNames.createWorkoutProgram,
                    //         //   extra: program,
                    //         // );
                    //         break;
                    //       case 'delete':
                    //         onDelete.call();
                    //         //DeleteDialog(itemName: program.title);
                    //         break;
                    //     }
                    //   },
                    //   itemBuilder: (_) => [
                    //     const PopupMenuItem(
                    //       value: 'edit',
                    //       child: Text(
                    //         'Edit',
                    //         style: TextStyle(color: _charcoal),
                    //       ),
                    //     ),
                    //     const PopupMenuItem(
                    //       value: 'delete',
                    //       child: Text(
                    //         'Delete',
                    //         style: TextStyle(color: _orange),
                    //       ),
                    //     ),
                    //   ],
                    //   child: Icon(
                    //     Icons.more_horiz_rounded,
                    //     size: 20,
                    //     color: _charcoal.withOpacity(0.6),
                    //   ),
                    // ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.flag_rounded,
                      text: program.goal.name,
                    ),
                    _InfoChip(
                      icon: Icons.bar_chart_rounded,
                      text: program.level.name,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 4),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: _orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${program.daysPerWeek} روز در هفته',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: _charcoal.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _orange),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: _charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
