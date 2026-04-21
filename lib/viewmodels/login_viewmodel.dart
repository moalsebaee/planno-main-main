import 'package:flutter/foundation.dart';
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
