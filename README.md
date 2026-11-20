# 📱 Circle — Flutter Mobile App

This is the mobile app for **Circle** (College Companion App). It is built using Flutter and Dart.

For the full guide and backend setup, see the [Main Project README](../README.md).

---

## 🚀 Quick Start for App Devs

### 1. Get packages
```bash
flutter pub get
```

### 2. Connect a phone or start an emulator
Run `flutter devices` to make sure your phone or emulator is detected.

### 3. Run the app
```bash
flutter run
```

### 4. Build an APK for your Android phone
```bash
flutter build apk --release
```
Your APK will be ready at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 Key Folders Inside `lib/`

- **`features/attendance`**: Live AKGEC ERP attendance screen, bunk & target attendance calculator.
- **`features/notes`**: Notes list by semester/subject, PDF viewer, and file uploader.
- **`features/societies`**: College clubs, event listings, and registration links.
- **`features/chatbot`**: Campus AI chat screen with quick prompt buttons.
- **`features/auth`**: Login and registration screens.
- **`app/theme`**: App colors and fonts (`Chicle` and `KaushanScript`).
- **`core/services`**: `api_service.dart` handles all calls to the backend server.
