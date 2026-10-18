import 'package:coach_studio/core/widgets/display/app_status_chip.dart';
import 'package:flutter/material.dart';

class CoachStatusChip extends StatelessWidget {
  final bool isActive;
  const CoachStatusChip({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(
      label: isActive ? 'فعال' : 'غیرفعال',
      type: isActive ? AppStatusType.success : AppStatusType.error,
    );
  }
}
