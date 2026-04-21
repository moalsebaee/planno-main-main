import 'package:firebase_auth/firebase_auth.dart';
// import '../../models/user_model.dart';

abstract class AuthRepository {
  User? get currentUser;
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> updateDisplayName(String fullName);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
