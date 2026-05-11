import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planno/core/repositories/auth_repository_impl.dart';
import 'package:planno/core/repositories/focus_repository.dart';
import 'package:planno/models/focus_session.dart';

/// ViewModel for focus session management.
/// Automatically scopes all data to the currently authenticated user.
/// Cancels existing streams and clears local state on logout to prevent
/// data leakage between sessions.
class FocusViewModel extends ChangeNotifier {
  final FocusRepository _focusRepository = FocusRepository();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  List<FocusSession> _sessions = [];
  bool _isLoading = true;

  StreamSubscription<List<FocusSession>>? _sessionsSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<FocusSession> get sessionsList => _sessions;
  bool get isLoading => _isLoading;
  Stream<List<FocusSession>> get sessions =>
      _focusRepository.streamFocusSessions();

  FocusViewModel() {
    _listenToAuth();
  }

  void _listenToAuth() {
    _subscribeToSessions();

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _subscribeToSessions();
    });
  }

  void _subscribeToSessions() {
    _sessionsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _sessionsSubscription = _focusRepository.streamFocusSessions().listen(
      (sessions) {
        _sessions = sessions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Focus session stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addFocusSession({
    required int durationSeconds,
    String? associatedTaskTitle,
  }) async {
    final session = FocusSession(
      id: '',
      durationSeconds: durationSeconds,
      date: DateTime.now(),
      associatedTaskTitle: associatedTaskTitle,
    );
    try {
      await _focusRepository.addFocusSession(session);
      notifyListeners();
    } catch (e) {
      debugPrint('Add focus session error: $e');
    }
  }

  /// Clears local state. Call this on explicit logout if needed.
  void clear() {
    _sessionsSubscription?.cancel();
    _sessions = [];
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
