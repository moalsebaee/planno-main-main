# TODO: Dynamic Profile + Edit Profile Implementation

## Steps
1. [x] Edit `lib/services/firestore_service.dart` — add `getUserStream`, `updateUserName`, `updateUserImageUrl`.
2. [x] Create `lib/viewmodels/profile_viewmodel.dart` — new ViewModel with real-time Firestore stream, edit name/image methods.
3. [x] Edit `lib/screens/profile_screen.dart` — dynamic user data, NetworkImage avatar, edit profile bottom sheet, loading/error states.
4. [x] Edit `lib/main.dart` — register `ProfileViewModel` in `MultiProvider`.

