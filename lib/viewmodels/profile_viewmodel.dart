import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/repositories/auth_repository_impl.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String? errorMessage;

  StreamSubscription? _userSubscription;
  StreamSubscription? _authSubscription;

  ProfileViewModel() {
    _init();
  }

  void _init() {
    _listenToAuth();
  }

  void _listenToAuth() {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _listenToUser(currentUser.uid);
    } else {
      _isLoading = false;
      notifyListeners();
    }

    _authSubscription = _authRepository.authStateChanges.listen((authUser) {
      if (authUser != null) {
        _listenToUser(authUser.uid);
      } else {
        _user = null;
        _userSubscription?.cancel();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToUser(String uid) {
    _userSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _userSubscription = _firestoreService
        .getUserStream(uid)
        .listen(
          (userModel) {
            _user = userModel;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            errorMessage = 'Failed to load profile: $e';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> updateName(String newName) async {
    if (_user == null) return;
    _isEditing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser!.uid;
      await _firestoreService.updateUserName(uid, newName);
      await _authRepository.updateDisplayName(newName);
    } catch (e) {
      errorMessage = 'Failed to update name: $e';
      notifyListeners();
    } finally {
      _isEditing = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(XFile imageFile) async {
    if (_user == null) return;
    _isEditing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = _authRepository.currentUser!.uid;
      final imageUrl = await _storageService.uploadProfileImage(uid, imageFile);
      if (imageUrl != null) {
        await _firestoreService.updateUserImageUrl(uid, imageUrl);
      } else {
        errorMessage = 'Image upload failed';
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to update image: $e';
      notifyListeners();
    } finally {
      _isEditing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
