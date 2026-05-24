import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  String? errorMessage;
  XFile? _selectedImage;

  String? get imagePath => _selectedImage?.path;

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
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await StorageService().uploadProfileImage(
            user.uid,
            _selectedImage!,
          );
          if (imageUrl == null) {
            errorMessage = 'Image upload failed, but account created';
          }
        }
        await _authService.updateDisplayName(fullName);
        await FirestoreService().createUserRecord(
          uid: user.uid,
          name: fullName,
          email: email,
          imageUrl: imageUrl,
        );
      }
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/Password is not enabled';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred';
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

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      _selectedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (_selectedImage != null) {
        errorMessage = null;
      } else {
        errorMessage = 'No image selected';
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void setSelectedImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clear() {
    fullName = '';
    email = '';
    password = '';
    confirmPassword = '';
    errorMessage = null;
    isLoading = false;
    _selectedImage = null;
    notifyListeners();
  }
}
