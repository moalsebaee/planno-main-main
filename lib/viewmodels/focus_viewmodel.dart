import 'package:flutter/material.dart';
import 'package:planno/core/repositories/focus_repository.dart';
import 'package:planno/models/focus_session.dart';

class FocusViewModel extends ChangeNotifier {
  final FocusRepository _focusRepository = FocusRepository();

  Stream<List<FocusSession>> get sessions =>
      _focusRepository.streamFocusSessions();

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
    await _focusRepository.addFocusSession(session);
    notifyListeners();
  }
}
