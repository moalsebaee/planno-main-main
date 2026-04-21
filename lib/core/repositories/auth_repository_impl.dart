import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static final AuthRepositoryImpl _instance = AuthRepositoryImpl._internal();
  factory AuthRepositoryImpl() => _instance;
  AuthRepositoryImpl._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? get currentUser => _auth.currentUser;

  String? _mapErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorCode(e.code) ?? e.message);
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorCode(e.code) ?? e.message);
    }
  }

  @override
  Future<void> updateDisplayName(String fullName) async {
    try {
      await _auth.currentUser?.updateDisplayName(fullName);
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
