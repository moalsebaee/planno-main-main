# Complete Sign Up Flow with Image Upload

## Current Progress:
Ready to implement.

## Detailed Steps:

1. ✅ **Update pubspec.yaml**: Add `image_picker: ^1.1.2` and `firebase_storage: ^12.3.3`
2. ✅ **Run `flutter pub get`**
3. ✅ **Update `lib/models/user_model.dart`**: Add `String? imageUrl`, update constructor/fromMap
4. ✅ **Create `lib/services/storage_service.dart`**: Singleton, uploadProfileImage(uid, XFile)
5. ✅ **Update `lib/services/firestore_service.dart`**: Add imageUrl param to createUserRecord
6. ✅ **Update `lib/viewmodels/signup_viewmodel.dart`**: Add selectedImage (XFile?), pickImage(), upload logic in signUp()
7. 🔄 **Update `lib/screens/signup_screen.dart`**: Profile tap -> VM.pickImage(), show preview if selected
8. **Test**: flutter run, signup with/without image, verify Firebase Console
9. **Complete**

**Notes**:
- Image optional
- Compress: imageQuality: 70 in pickImage
- Path: users/{uid}/profile.jpg
- Nav to TaskHomeScreen after success


