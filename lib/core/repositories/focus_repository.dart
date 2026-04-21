import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planno/models/focus_session.dart';

class FocusRepository {
  Stream<List<FocusSession>> streamFocusSessions([String? uid]) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'focus_sessions',
    );
    if (uid != null) {
      query = query.where('userId', isEqualTo: uid);
    }
    return query
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FocusSession.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addFocusSession(FocusSession session) async {
    await FirebaseFirestore.instance.collection('focus_sessions').add({
      ...session.toFirestore(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });
  }
}
