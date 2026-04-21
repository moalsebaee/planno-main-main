import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task.dart';

class FirestoreRepository {
  static final FirestoreRepository _instance = FirestoreRepository._internal();
  factory FirestoreRepository() => _instance;
  FirestoreRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserRecord({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    } catch (e) {
      throw Exception('Failed to create user record: $e');
    }
  }

  Stream<List<Task>> tasksStream() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(String id, Task task) async {
    try {
      await _firestore.collection('tasks').doc(id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
