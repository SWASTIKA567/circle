# 🎓 Circle — College Companion App

> A cross-platform mobile app for college students to track live ERP attendance, share study notes (PDFs), explore campus clubs, and chat with an AI assistant.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/State-GetX-8A2BE2)](https://pub.dev/packages/get)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?logo=node.js&logoColor=white)](https://github.com/SWASTIKA567/circle_backend)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB-47A248?logo=mongodb&logoColor=white)](https://mongodb.com)

---

## ✨ Features

- **📊 Live ERP Attendance**: Connects to the college ERP to show subject-wise attendance and a bunk/target calculator (how many classes you can skip or need to attend).
- **📚 Notes Hub**: Browse, read, and upload study notes (PDFs) filtered by semester and subject.
- **🎭 Societies & Events**: Discover campus clubs, view upcoming events, and access registration links.
- **🤖 Campus AI Bot**: Ask questions about college locations, fests, rules, and notes.

---

## 📱 App Development (Flutter)

The mobile app is built with **Flutter** and uses **GetX** for state management and navigation.

### 📂 Key Folders in `lib/`

| Folder | What it handles |
| :--- | :--- |
| `features/attendance` | ERP attendance screen & bunk calculator |
| `features/notes` | Notes catalog, PDF viewer & uploader |
| `features/societies` | Clubs and event listings |
| `features/chatbot` | AI query assistant |
| `features/auth` | Login and student signup |
| `app/theme` | Colors and custom fonts (`Chicle`, `KaushanScript`) |
| `core/services` | `api_service.dart` (handles backend API calls) |

### 🚀 How to Run the App

1. **Install packages**:
   ```bash
   flutter pub get
   ```
2. **Run on phone or emulator**:
   ```bash
   flutter run
   ```
3. **Build Android APK**:
   ```bash
   flutter build apk --release
   ```
   *The APK will be saved in: `build/app/outputs/flutter-apk/app-release.apk`*

---

## ⚙️ How the Whole Tech Works

```
[ Mobile App (Flutter) ] ──▶ [ Backend API (Node.js / Express) ]
                                  ├── MongoDB (User accounts & notes info)
                                  ├── Cloudinary (PDF & image storage)
                                  ├── AKGEC ERP (Fetches live attendance)
                                  └── AI Chatbot (Answers campus FAQs)
```

- **Backend Repository**: [circle_backend](https://github.com/SWASTIKA567/circle_backend) (hosted on Render)
- **Database**: MongoDB Atlas for storing users, notes info, and club data
- **File Storage**: Cloudinary CDN for storing notes PDFs
- **Security**: AES-256 encrypted ERP passwords & JWT login tokens

---

## 💡 Quick Tips

- **Testing with Local Backend**: Change `baseUrl` in `lib/core/services/api_service.dart` to `http://10.0.2.2:5000/api` (Android emulator) or your local computer IP (physical phone).
- **Build issues?** Run `flutter clean` followed by `flutter pub get`.
