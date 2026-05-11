# User Data Isolation - Implementation Tracker

## Goal: Ensure EACH USER has completely separate data in Firestore

---

## Steps

- [x] Step 1: Update `lib/services/firestore_service.dart` — Consolidate ALL Firestore CRUD logic, retrieve uid internally, use subcollections `users/{uid}/tasks` and `users/{uid}/focus_sessions`
- [x] Step 2: Update `lib/core/repositories/task_repository.dart` — Delegate to FirestoreService, no manual uid passing
- [x] Step 3: Update `lib/core/repositories/focus_repository.dart` — Move to user-scoped subcollection
- [x] Step 4: Update `lib/core/repositories/firestore_repository.dart` — Remove task methods (deprecated, user profile logic moved to FirestoreService)
- [x] Step 5: Update `lib/viewmodels/task_viewmodel.dart` — Auth-aware, cancel streams on auth change, clear data on logout
- [x] Step 6: Update `lib/viewmodels/focus_viewmodel.dart` — Auth-aware, cancel streams on auth change, clear data on logout
- [x] Step 7: Update `lib/screens/new_task_screen.dart` — Task creation already flows through TaskViewModel correctly
- [x] Step 8: Create `firestore.rules` — Strict per-user access rules
- [x] Step 9: Update `firebase.json` — Reference rules file
- [x] Step 10: Update `lib/models/user_model.dart` — Support `fullName` with backward compatibility to `name`
- [x] Step 11: Verified no global `collection('tasks')` or `collection('focus_sessions')` references remain

---

## Architecture Summary

```
UI (Screens)
    ↓
ViewModels (TaskViewModel, FocusViewModel, ProfileViewModel)
    ↓ listens to auth state → auto-cancels & re-subscribes on login/logout
Repositories (TaskRepository, FocusRepository)
    ↓ delegates to
FirestoreService (singleton, uid retrieved internally via FirebaseAuth)
    ↓ writes/reads to
Firestore: users/{uid}/tasks
          users/{uid}/focus_sessions
          users/{uid} (profile)
```

## Key Behaviors

1. **New user signup**: `FirestoreService.createUserRecord()` creates `users/{uid}` with empty/default values.
2. **Task creation**: Saved to `users/{uid}/tasks/{autoId}` via `FirestoreService.addTask()`.
3. **Task fetching**: `TaskViewModel` listens to `users/{uid}/tasks` stream; returns empty list when logged out.
4. **Logout**: `AuthViewModel.logout()` → FirebaseAuth emits null → `TaskViewModel` & `FocusViewModel` cancel streams and clear local lists → no data leakage.
5. **Security**: Firestore rules enforce `request.auth.uid == userId` for all `users/{userId}` and nested documents.

