import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// DEPRECATED: This class is being phased out in favor of [FirestoreService].
/// User profile operations have been consolidated into [FirestoreService].
///
/// Kept temporarily for any lingering references. Prefer using
/// [FirestoreService] directly for all new code.
class FirestoreRepository {
  static final FirestoreRepository _instance = FirestoreRepository._internal();
  factory FirestoreRepository() => _instance;
  FirestoreRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Legacy user profile helpers (forward to FirestoreService) ───────────

  Future<void> createUserRecord({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    } catch (e) {
      throw Exception('Failed to create user record: $e');
    }
  }
}
