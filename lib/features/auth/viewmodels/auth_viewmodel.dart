import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/repositories/auth_repository_impl.dart';
import '../../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  User? get currentUser => _authRepository.currentUser;
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  String? errorMessage;

  Future<void> logout() async {
    _isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
