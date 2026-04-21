import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  String? errorMessage;

  bool validateFullName() {
    if (fullName.isEmpty) {
      errorMessage = 'Full name is required';
      notifyListeners();
      return false;
    }
    return true;
  }

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

  bool validateConfirmPassword() {
    if (confirmPassword.isEmpty) {
      errorMessage = 'Please confirm your password';
      notifyListeners();
      return false;
    }
    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }
    return true;
  }

  bool validate() {
    errorMessage = null;
    return validateFullName() &&
        validateEmail() &&
        validatePassword() &&
        validateConfirmPassword();
  }

  Future<bool> signUp() async {
    if (!validate()) {
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (credential?.user != null) {
        final user = credential!.user!;
        await _authService.updateDisplayName(fullName);
        await FirestoreService().createUserRecord(
          uid: user.uid,
          name: fullName,
          email: email,
        );
      }
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
    fullName = '';
    email = '';
    password = '';
    confirmPassword = '';
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
