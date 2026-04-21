import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planno/models/task.dart';
import 'firestore_repository.dart';

class TaskRepository {
  final FirestoreRepository _firestoreRepo = FirestoreRepository();

  Stream<List<Task>> streamTasks([String? uid]) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('tasks');
    if (uid != null) {
      query = query.where('assignedTo', isEqualTo: uid);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  Future<void> addTask(Task task) => _firestoreRepo.addTask(task);

  Future<void> updateTask(String id, Task task) =>
      _firestoreRepo.updateTask(id, task);

  Future<void> deleteTask(String id) => _firestoreRepo.deleteTask(id);

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('tasks').doc(id).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final task = Task.fromMap(data, id);
      final updatedTask = Task(
        id: id,
        title: task.title,
        status: isCompleted ? 'completed' : 'pending',
        progress: isCompleted ? 1.0 : 0.0,
        assignedTo: task.assignedTo,
        createdAt: task.createdAt,
        deadline: task.deadline,
      );
      await _firestoreRepo.updateTask(id, updatedTask);
    }
  }
}
