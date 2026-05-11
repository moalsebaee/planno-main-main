import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/focus_session.dart';
import '../models/task.dart';
import '../models/user_model.dart';

/// Singleton service for ALL Firestore operations.
/// Every read/write is automatically scoped to the currently authenticated user.
/// Retrieves [uid] internally — callers must NOT pass it manually.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Returns the current user's UID or null if not signed in.
  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  /// Reusable accessor for user-scoped tasks collection: users/{uid}/tasks
  CollectionReference<Map<String, dynamic>> userTasks(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  /// Builds the user-scoped focus_sessions collection reference.
  /// Returns null if no user is authenticated.
  CollectionReference<Map<String, dynamic>>? get _focusSessionsCollection {
    final uid = _currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('focus_sessions');
  }

  DocumentReference<Map<String, dynamic>>? _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  void _assertAuthenticated() {
    if (_currentUid == null) {
      throw Exception('User is not authenticated');
    }
  }

  // ─── User Profile ────────────────────────────────────────────────────────

  Future<void> createUserRecord({
    required String uid,
    required String name,
    required String email,
    String? imageUrl,
  }) async {
    try {
      final userData = <String, dynamic>{
        'fullName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      };
      if (imageUrl != null) {
        userData['imageUrl'] = imageUrl;
      }
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      throw Exception('Failed to create user record: $e');
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> updateUserName(String uid, String name) async {
    try {
      await _firestore.collection('users').doc(uid).update({'fullName': name});
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }

  Future<void> updateUserImageUrl(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update image URL: $e');
    }
  }

  // ─── Tasks (user-scoped: users/{uid}/tasks) ──────────────────────────────

  Stream<List<Task>> tasksStream() {
    final uid = _currentUid;
    if (uid == null) {
      // Return empty stream when not authenticated to prevent data leakage
      return Stream.value(<Task>[]);
    }

    final collection = userTasks(uid);
    return collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Create task using a fixed document ID (users/{uid}/tasks/{task.id}).
  /// IMPORTANT: [task.id] must be non-empty.
  Future<void> addTask(Task task) async {
    _assertAuthenticated();
    if (task.id.isEmpty) {
      throw Exception('Task ID cannot be empty');
    }

    final uid = _currentUid!;
    final collection = userTasks(uid);

    try {
      await collection.doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Safely updates a task document with field-level updates.
  ///
  /// Only the keys present in [fields] will be updated.
  Future<void> updateTaskFields(String id, Map<String, dynamic> fields) async {
    _assertAuthenticated();
    final uid = _currentUid!;
    final collection = userTasks(uid);

    // Never send an empty update.
    if (fields.isEmpty) return;

    try {
      await collection.doc(id).update(fields);
    } catch (e) {
      throw Exception('Failed to update task fields: $e');
    }
  }

  /// Backwards-compatible helper: update whole task using .update().
  /// NOTE: Prefer [updateTaskFields] for granular edits.
  Future<void> updateTask(String id, Task task) async {
    await updateTaskFields(id, task.toMap());
  }

  // Field-specific helpers (granular, null-safe)
  Future<void> updateTaskTitle(String id, String? title) async {
    if (title == null) return;
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await updateTaskFields(id, {'title': trimmed});
  }

  Future<void> updateTaskPriority(String id, String? status) async {
    if (status == null) return;
    final trimmed = status.trim();
    if (trimmed.isEmpty) return;
    await updateTaskFields(id, {'status': trimmed});
  }

  Future<void> updateTaskDeadline(String id, DateTime? deadline) async {
    // If deadline is null, don't overwrite.
    if (deadline == null) return;
    await updateTaskFields(id, {'deadline': Timestamp.fromDate(deadline)});
  }

  // NOTE: This app's Task model currently has no category/description fields
  // in Firestore writes. Keep these as no-ops to avoid accidentally
  // overwriting unrelated fields.
  Future<void> updateTaskDescription(String id, String? description) async {
    return;
  }

  Future<void> updateTaskCategory(String id, String? category) async {
    return;
  }

  Future<void> deleteTask(String id) async {
    _assertAuthenticated();
    final uid = _currentUid!;
    final collection = userTasks(uid);

    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    _assertAuthenticated();
    final uid = _currentUid!;
    final collection = userTasks(uid);

    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Task not found');
      }
      final data = doc.data()!;
      final task = Task.fromMap(data, id);
      final updated = Task(
        id: id,
        title: task.title,
        status: isCompleted ? 'completed' : 'pending',
        progress: isCompleted ? 1.0 : 0.0,
        assignedTo: task.assignedTo,
        createdAt: task.createdAt,
        deadline: task.deadline,
      );
      await collection.doc(id).update(updated.toMap());
    } catch (e) {
      throw Exception('Failed to toggle task status: $e');
    }
  }

  // ─── Focus Sessions (user-scoped: users/{uid}/focus_sessions) ────────────

  Stream<List<FocusSession>> focusSessionsStream() {
    final collection = _focusSessionsCollection;
    if (collection == null) {
      return Stream.value(<FocusSession>[]);
    }
    return collection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => FocusSession.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addFocusSession(FocusSession session) async {
    _assertAuthenticated();
    final collection = _focusSessionsCollection!;
    try {
      await collection.add(session.toFirestore());
    } catch (e) {
      throw Exception('Failed to add focus session: $e');
    }
  }
}
