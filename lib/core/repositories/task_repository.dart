import 'package:planno/models/task.dart';
import '../../services/firestore_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for task-related operations.
/// All data is automatically scoped to the current authenticated user
/// via [FirestoreService]; no manual uid passing is required.
class TaskRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<Task>> streamTasks() => _firestoreService.tasksStream();

  Future<void> addTask(Task task) => _firestoreService.addTask(task);

  Future<void> updateTask(String id, Task task) =>
      _firestoreService.updateTask(id, task);

  Future<void> updateTaskTitle(String id, String? title) =>
      _firestoreService.updateTaskTitle(id, title);

  Future<void> updateTaskDescription(String id, String? description) =>
      _firestoreService.updateTaskDescription(id, description);

  Future<void> updateTaskPriority(String id, String? status) =>
      _firestoreService.updateTaskPriority(id, status);

  Future<void> updateTaskDeadline(String id, DateTime? deadline) =>
      _firestoreService.updateTaskDeadline(id, deadline);

  Future<void> updateTaskCategory(String id, String? category) =>
      _firestoreService.updateTaskCategory(id, category);

  Future<void> deleteTask(String id) => _firestoreService.deleteTask(id);

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    await _firestoreService.toggleTaskStatus(id, isCompleted);
  }
}
