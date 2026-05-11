import 'package:planno/models/focus_session.dart';
import '../../services/firestore_service.dart';

/// Repository for focus-session-related operations.
/// All data is automatically scoped to the current authenticated user
/// via [FirestoreService]; no manual uid passing is required.
class FocusRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<FocusSession>> streamFocusSessions() =>
      _firestoreService.focusSessionsStream();

  Future<void> addFocusSession(FocusSession session) =>
      _firestoreService.addFocusSession(session);
}
