import 'package:flutter/material.dart';
import 'package:planno/core/repositories/task_repository.dart';
import 'package:planno/models/task.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  List<Task> _tasks = [];
  bool _isLoading = false;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  Stream<List<Task>> get tasksStream => _taskRepository.streamTasks();

  TaskViewModel() {
    // Listen to stream for real-time updates
    _taskRepository.streamTasks().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _taskRepository.toggleTaskStatus(taskId, isCompleted);
      // Stream will auto-refresh
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _taskRepository.addTask(task);
      // Stream will auto-refresh
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  Future<void> updateTask(String taskId, Task task) async {
    try {
      await _taskRepository.updateTask(taskId, task);
      // Stream will auto-refresh
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  int get totalTasks => _tasks.length;

  List<Task> get todayTasks =>
      _tasks.where((t) => _isToday(t.createdAt)).toList();
}
