# 🎓 Circle — College Companion Mobile App

Circle is an all-in-one mobile app built for college students. It helps you check your live college attendance, find and share study notes (PDFs), explore college clubs and events, and get quick answers from a campus AI chatbot.

> 🔗 **Backend Repository**: Looking for the server code? Visit [circle_backend](https://github.com/SWASTIKA567/circle_backend).

---

## 📑 What's Inside This Guide

1. [What Does the App Do?](#-what-does-the-app-do)
2. [How the Whole Project Works (Simple Tech Overview)](#-how-the-whole-project-works-simple-tech-overview)
3. [App Development Guide (Flutter)](#-app-development-guide-flutter)
   - [Screens & What They Do](#screens--what-they-do)
   - [How State and Code Are Managed (GetX)](#how-state-and-code-are-managed-getx)
   - [Colors, Fonts, and Look](#colors-fonts-and-look)
   - [How the App Talks to the Backend](#how-the-app-talks-to-the-backend)
   - [Step-by-Step: How to Run the App](#step-by-step-how-to-run-the-app)
   - [How to Build an APK for Your Phone](#how-to-build-an-apk-for-your-phone)
4. [Backend Overview (Node.js & Express)](#-backend-overview-nodejs--express)
   - [Main Backend Parts](#main-backend-parts)
   - [How College ERP Attendance Works](#how-college-erp-attendance-works)
5. [Folder Structure](#-folder-structure)
6. [Easy Troubleshooting](#-easy-troubleshooting)

---

## ✨ What Does the App Do?

- **📊 Live College Attendance**: Connects directly with the college ERP. Shows your subject-wise attendance and tells you how many classes you can safely miss or need to attend to stay above 75%.
- **📚 Notes Sharing Hub**: Download or view PDFs for your branch, semester, subject, and unit. You can also upload your own notes to help classmates.
- **🎭 College Clubs & Societies**: See all active campus societies, what they do, who is in charge, and their upcoming events and registration links.
- **🤖 Campus AI Chatbot**: Ask questions about college places (like the ATM, canteen, amphitheatre), fests, rules, and notes.
- **🎨 Fresh & Fun Design**: Clean card-based design with bright colors and easy-to-read custom fonts.

---

## 🧩 How the Whole Project Works (Simple Tech Overview)

Here is a simple picture of how the mobile app connects to the whole system:

```
[ Your Phone (Flutter App) ]
            │
            │  (Sends requests like login, get notes, check attendance)
            ▼
[ Backend Server (Node.js + Express) ]
      │             │               │                 │
      ▼             ▼               ▼                 ▼
 [ MongoDB ]   [ Cloudinary ]   [ College ERP ]   [ AI Chatbot ]
 (Saves users   (Saves notes    (Pulls real       (Answers campus
  & note info)   PDF files)      attendance)       questions)
```

### The Tech Stack in Plain Words

- **Mobile App**: Built with **Flutter** (using Dart). Works smoothly on Android and iOS phones.
- **State Management**: **GetX** (keeps screens updated in real time when data changes).
- **Backend API**: **Node.js** and **Express.js** (hosted on Render; handles logins and fetches ERP data).
- **Database**: **MongoDB Atlas** (stores student profiles, notes information, and club details).
- **File Storage**: **Cloudinary** (stores uploaded PDF notes and images safely in the cloud).
- **College ERP Sync**: The server logs into the college portal safely to fetch your latest attendance numbers.

---

## 📱 App Development Guide (Flutter)

If you are working on the mobile app, this section covers everything you need to know.

### Screens & What They Do

All app features are organized inside the `lib/features/` directory:

| Screen / Feature | What It Does |
| :--- | :--- |
| **`splash`** | The startup screen. Checks if you are already logged in. If yes, takes you to Home; otherwise, shows Login. |
| **`auth`** | Lets students sign up or log in with their email, student number, and password. |
| **`home`** | The main bottom-navigation hub connecting all tabs. |
| **`attendance`** | Displays overall and subject-by-subject attendance. Has a built-in bunk calculator (e.g., "You can skip 2 classes" or "Attend 3 more classes for 75%"). Also saves attendance offline so you can see it without internet. |
| **`notes`** | Browse notes filtered by semester and subject. Tap to open or download PDFs. Click the upload button to pick and share a PDF file. |
| **`societies`** | Lists campus societies and upcoming college events with direct registration links. Society heads can also log in to add new events. |
| **`chatbot`** | A chat screen where you can type questions or tap quick suggestion chips to ask Circle AI. |
| **`admin`** | A special screen for admins to manage users and verify uploaded notes. |

---

### How State and Code Are Managed (GetX)

We use **GetX** because it is simple, fast, and doesn't require complicated boilerplate code:

1. **Variables that update automatically (`.obs`)**:
   ```dart
   // When this value changes, the UI updates on its own!
   var isLoading = false.obs;
   var notes = <NoteModel>[].obs;
   ```

2. **Showing reactive data on screen (`Obx`)**:
   ```dart
   Obx(() {
     if (controller.isLoading.value) {
       return const CircularProgressIndicator();
     }
     return Text("Total Notes: ${controller.notes.length}");
   })
   ```

3. **Simple Page Switching**:
   ```dart
   Get.toNamed(Routes.HOME);   // Go to home screen
   Get.back();                 // Go back to previous screen
   ```

---

### Colors, Fonts, and Look

The styling is defined in `lib/app/theme/app_theme.dart`:
- **Background**: Soft white (`#F8F8F8`)
- **Cards**: Dark charcoal (`#222222`)
- **Accent Colors**: Soft Purple (`#C39AF0`), Light Green (`#83E94F`), Light Blue (`#B8C8F0`), Pink (`#F0A5B8`)
- **Custom Fonts**:
  - `Chicle`: Used for big bold headings and attendance percentages.
  - `KaushanScript`: Used for handwritten-style labels and note tags.

---

### How the App Talks to the Backend

All network requests go through one file:
`lib/core/services/api_service.dart`.

- By default, it connects to the live backend on Render:
  `https://circle-backend-e52p.onrender.com/api`
- It automatically adds your login token to requests so you stay logged in.
- If you lose internet, it catches the error and shows a friendly message instead of crashing.

---

### Step-by-Step: How to Run the App

#### Step 1: Check Prerequisites
Make sure you have installed:
- **Flutter SDK**
- **Android Studio** (or VS Code with the Flutter extension)
- A connected Android phone (with USB debugging turned on) or an Android Emulator

Check that everything is ready:
```bash
flutter doctor
```

#### Step 2: Get all packages
```bash
flutter pub get
```

#### Step 3: Run the app
```bash
flutter run
```
The app will build and launch on your phone or emulator!

> 💡 **Tip for testing with a local backend:**
> If you are running the backend on your own machine instead of the cloud:
> - On Android Emulator, change the base URL in `api_service.dart` to `http://10.0.2.2:5000/api`.
> - On a real phone connected to your Wi-Fi, change it to your computer's local IP (e.g. `http://192.168.1.10:5000/api`).

---

### How to Build an APK for Your Phone

To install the app on an Android phone or share it with friends:

```bash
flutter build apk --release
```

Once it finishes, your APK file will be ready at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🖥 Backend Overview (Node.js & Express)

The backend runs as a separate Node.js service ([circle_backend repository](https://github.com/SWASTIKA567/circle_backend)).

### Main Backend Parts
- **Auth Routes (`/api/auth`)**: Handles user registration, student number verification, and secure logins.
- **Attendance Routes (`/api/attendance`)**: Connects to the college ERP to pull real-time student attendance.
- **Notes Routes (`/api/notes`)**: Handles notes search, filtering, and PDF uploads to Cloudinary.
- **Societies Routes (`/api/societies`)**: Lets students view societies and leads manage their events.
- **Chatbot Routes (`/api/chatbot`)**: Forwards student questions to the campus AI model.

### How College ERP Attendance Works
1. The student enters their ERP password in the app.
2. The server encrypts the password using strong **AES-256** encryption so nobody can see it.
3. When the student opens the attendance screen, the server logs into the AKGEC ERP portal in the background.
4. It reads the latest attendance records and sends them back to the app in clean JSON format.

---

## 📁 Folder Structure

```text
college_notes/
├── assets/                    # Logo, icons, and custom fonts (Chicle, KaushanScript)
├── lib/
│   ├── app/
│   │   ├── routes/            # Screen navigation paths (app_pages.dart, app_routes.dart)
│   │   └── theme/             # App colors and styles (app_theme.dart)
│   ├── core/services/         # API network helper (api_service.dart)
│   ├── features/              # Screens & logic
│   │   ├── attendance/        # Attendance tracker & bunk calculator
│   │   ├── auth/              # Login & sign up
│   │   ├── chatbot/           # AI helper chat
│   │   ├── home/              # Main navigation & dashboard
│   │   ├── notes/             # Notes viewer & PDF uploader
│   │   └── societies/         # Clubs and events
│   └── main.dart              # App starting point
└── pubspec.yaml               # Flutter packages list
```

---

## 🛠 Easy Troubleshooting

- **App won't build or says packages are missing?**
  Run:
  ```bash
  flutter clean
  flutter pub get
  ```
- **"Could not connect to server"?**
  Check your internet connection. If testing locally, make sure your computer and phone are on the same Wi-Fi network.
- **Attendance takes a few seconds to load?**
  The first time you fetch attendance, the server is logging into the college ERP system. Once loaded, the app saves it on your phone so you can see it instantly next time.
- **Need to test on a physical Android phone?**
  Turn on **Developer Options** and enable **USB Debugging** on your phone, plug it in with a USB cable, and run `flutter run`.

---

<p align="center">
  Made with ❤️ to make college life simpler and better!
</p>
