import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FocusSession {
  final String id;
  final int durationSeconds;
  final DateTime date;
  final String? associatedTaskTitle;

  FocusSession({
    required this.id,
    required this.durationSeconds,
    required this.date,
    this.associatedTaskTitle,
  });

  int get durationInMinutes => durationSeconds ~/ 60;

  static FocusSession fromFirestore(Map<String, dynamic> data, String id) {
    return FocusSession(
      id: id,
      durationSeconds: data['durationSeconds'] ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      associatedTaskTitle: data['associatedTaskTitle'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'durationSeconds': durationSeconds,
      'date': FieldValue.serverTimestamp(),
      'associatedTaskTitle': associatedTaskTitle,
    };
  }
}
