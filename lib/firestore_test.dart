import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestore() async {
  await FirebaseFirestore.instance.collection('exercises').add({
    'name': 'Bench Press',
    'targetMuscle': 'Chest',
    'difficulty': 'Intermediate',
    'equipment': 'Barbell',
    'isActive': true,
  });

  print('Exercise added successfully');
}
