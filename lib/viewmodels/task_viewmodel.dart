import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planno/core/repositories/auth_repository_impl.dart';
import 'package:planno/core/repositories/task_repository.dart';
import 'package:planno/models/task.dart';

/// ViewModel for task management.
/// Automatically scopes all data to the currently authenticated user.
/// Cancels existing streams and clears local state on logout to prevent
/// data leakage between sessions.
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  List<Task> _tasks = [];
  bool _isLoading = true;

  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  Stream<List<Task>> get tasksStream => _taskRepository.streamTasks();

  TaskViewModel() {
    _listenToAuth();
  }

  void _listenToAuth() {
    // Subscribe immediately so we get an empty stream when logged out
    _subscribeToTasks();

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      // Cancel old subscription and re-subscribe for the new user (or empty)
      _subscribeToTasks();
    });
  }

  void _subscribeToTasks() {
    _tasksSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _taskRepository.streamTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Task stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
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
      // IMPORTANT: do not swallow. Let UI know the write failed.
      rethrow;
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

  // Field-based granular updates
  Future<void> updateTaskTitle(String taskId, String? title) async {
    try {
      await _taskRepository.updateTaskTitle(taskId, title);
    } catch (e) {
      debugPrint('Update title error: $e');
    }
  }

  Future<void> updateTaskDescription(String taskId, String? description) async {
    try {
      await _taskRepository.updateTaskDescription(taskId, description);
    } catch (e) {
      debugPrint('Update description error: $e');
    }
  }

  Future<void> updateTaskPriority(String taskId, String? status) async {
    try {
      await _taskRepository.updateTaskPriority(taskId, status);
    } catch (e) {
      debugPrint('Update priority error: $e');
    }
  }

  Future<void> updateTaskDateTime(String taskId, DateTime? deadline) async {
    try {
      await _taskRepository.updateTaskDeadline(taskId, deadline);
    } catch (e) {
      debugPrint('Update deadline error: $e');
    }
  }

  Future<void> updateTaskCategory(String taskId, String? category) async {
    try {
      await _taskRepository.updateTaskCategory(taskId, category);
    } catch (e) {
      debugPrint('Update category error: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      // Stream will auto-refresh
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  /// Pending tasks are tasks that are not completed.
  List<Task> getPendingTasks() => _tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  int get totalTasks => _tasks.length;

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      return t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day;
    }).toList();
  }

  /// Clears local state. Call this on explicit logout if needed,
  /// although the auth listener handles it automatically.
  void clear() {
    _tasksSubscription?.cancel();
    _tasks = [];
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
