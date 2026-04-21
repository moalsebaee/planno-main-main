import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planno/core/repositories/task_repository.dart';
import 'package:planno/core/repositories/focus_repository.dart';
import 'package:planno/models/task.dart';
import 'package:planno/models/focus_session.dart';
import 'package:planno/viewmodels/focus_viewmodel.dart' show FocusViewModel;
import '../viewmodels/task_viewmodel.dart';

class StatsViewModel extends ChangeNotifier {
  final TaskViewModel taskViewModel;
  final FocusViewModel? focusViewModel;

  late final Stream<List<FocusSession>> sessions;
  int totalMinutes = 0;

  StatsViewModel({required this.taskViewModel, this.focusViewModel}) {
    sessions =
        focusViewModel?.sessions ?? FocusRepository().streamFocusSessions();
    // Listen to tasks stream for real-time updates
    taskViewModel.tasksStream.listen((tasks) {
      notifyListeners();
    });
  }
  String formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? "${h}h ${m}m" : "${m}m";
  }

  double get productivityScore {
    final tasks = taskViewModel.tasks;
    if (tasks.isEmpty) return 0.0;
    final completed = taskViewModel.completedTasks.length;
    return (completed / tasks.length) * 100;
  }

  String get formattedTime => formatTime(totalMinutes);

  String get formattedTotalFocusAllTime => formattedTime;

  int get totalTasks => taskViewModel.totalTasks;

  int get completedTasks => taskViewModel.completedTasks.length;

  String get weeklyTrend => '+12%'; // TODO: real trend

  Map<String, int> get weeklyData => weeklyCompletedTasks(taskViewModel.tasks);

  Map<String, int> weeklyCompletedTasks(List<Task> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final Map<String, int> weekly = {};
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      weekly[days[i]] = 0;
    }

    for (final task in tasks) {
      if (task.createdAt.isAfter(startOfWeek) && task.isCompleted) {
        final dayDiff = task.createdAt.difference(startOfWeek).inDays;
        final dayName = days[dayDiff.clamp(0, 6)];
        weekly[dayName] = (weekly[dayName] ?? 0) + 1;
      }
    }
    return weekly;
  }

  Map<String, int> weeklyTaskCounts(List<Task> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final Map<String, int> weekly = {};
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      weekly[days[i]] = 0;
    }

    for (final task in tasks) {
      if (task.createdAt.isAfter(startOfWeek) && task.isCompleted) {
        final dayDiff = task.createdAt.difference(startOfWeek).inDays;
        final dayName = days[dayDiff.clamp(0, 6)];
        weekly[dayName] = (weekly[dayName] ?? 0) + 1;
      }
    }
    return weekly;
  }

  double averageDailyTasks(List<Task> tasks) {
    final weekly = weeklyCompletedTasks(tasks);
    final values = weekly.values.toList();
    return values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;
  }

  Duration totalFocusThisWeek(List<FocusSession> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    int totalSeconds = 0;
    for (final session in sessions) {
      if (session.date.isAfter(startOfWeek)) {
        totalSeconds += session.durationSeconds;
      }
    }
    return Duration(seconds: totalSeconds);
  }

  void calculate(List<FocusSession> sessions) {
    totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  void onNewFocusSession() {
    notifyListeners();
  }

  void onTaskChanged() {
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}

extension ListAverage<T extends num> on List<T> {
  double get average => fold(0.0, (a, b) => a + b.toDouble()) / length;
}
