import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'completed'
  final double progress; // 0.0 to 1.0
  final String assignedTo; // user uid
  final DateTime createdAt;
  final DateTime? deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.assignedTo,
    required this.createdAt,
    this.deadline,
  });

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      assignedTo: map['assignedTo'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'progress': progress,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      if (deadline != null) 'deadline': Timestamp.fromDate(deadline!),
    };
  }

  bool get isCompleted => status == 'completed';

  // UI compatibility getters
  String get time => deadline != null
      ? '${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}'
      : '';

  String get category => 'Personal';

  bool get hasIndicator => progress > 0.5;

  IconData get categoryIcon => Icons.task_alt;

  DateTime get createdDate => createdAt;

  DateTime? get scheduledDate => deadline;

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }
}
