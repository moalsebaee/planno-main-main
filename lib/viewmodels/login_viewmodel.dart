import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  bool validateEmail() {
    if (email.isEmpty) {
      errorMessage = 'Email is required';
      notifyListeners();
      return false;
    }
    if (!email.contains('@')) {
      errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    return true;
  }

  bool validatePassword() {
    if (password.isEmpty) {
      errorMessage = 'Password is required';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    return true;
  }

  bool validate() {
    errorMessage = null;
    final validEmail = validateEmail();
    final validPassword = validatePassword();
    return validEmail && validPassword;
  }

  Future<bool> login() async {
    if (!validate()) {
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Password is incorrect';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred. Please try again';
      }

      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clear() {
    email = '';
    password = '';
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
