# 📝 Flutter To-Do List App By using Flutter with Dart,  (SQLite + Firebase)

A modern Flutter-based To-Do List mobile application supporting **hybrid task storage** using **SQLite** and **Firestore**, with real-time sync, **push notifications**, **local storage**, and **GetX state management**.

---

## 📱 Features

- ✅ Task creation, editing, and deletion
- 🔃 Sync tasks to both **Firestore** and **SQLite**
- 🔔 Schedule and receive **local push notifications**
- 🔍 Filter by **pending/completed**
- 📊 View task **statistics**
- 📅 Calendar view of tasks
- 🔐 User authentication (register/login/reset) via **FirebaseAuth**
- 💾 Persistent login using **SharedPreferences**
- 🌙 Dark mode support
- 📂 Checklist subtasks

---

## 🛠️ Tech Stack

| Feature                | Tool / Package                      |
|------------------------|--------------------------------------|
| **State Management**   | [GetX](https://pub.dev/packages/get) |
| **Database (Offline)** | [SQLite (sqflite)](https://pub.dev/packages/sqflite) |
| **Database (Online)**  | [Firebase Firestore](https://firebase.google.com/docs/firestore) |
| **Auth**               | [FirebaseAuth](https://firebase.google.com/docs/auth) |
| **Notifications**      | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Persistence**        | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Toasts**             | [oktoast](https://pub.dev/packages/oktoast) |

---

## 🚀 Getting Started

### 1. Clone the project

```bash
git clone https://github.com/nadineirakoze5/TODO-LIST.git
cd TODO-LIST
```
2. Install dependencies
```bash
flutter pub get
```
3. Firebase Setup

- Create a Firebase project

- Enable Authentication (Email/Password)

- Enable Firestore Database

- Download `google-services.json` and place it in `android/app/`

### Key Components
#### 🔐 Firebase Authentication
**Used for:**

- Registering users

- Signing in with email and password

- Resetting passwords

- Logic: `FirebaseAuth.instance.createUserWithEmailAndPassword(...)`

###  Firestore (Cloud Storage)
**Used for:**

- Storing task data in real-time

- Syncing across devices

- Each task is saved to collection('tasks').

### 🗂️ SQLite (Local DB)
**Used for:**

- Offline-first task storage

- Faster local operations

- Handled via DatabaseHelper with table: tasks.

### 🔔 Push Notifications
**Used for:**

- Notifying user before task start time

- Scheduled using: `flutterLocalNotificationsPlugin.zonedSchedule(...)`

###  State Management (GetX)
- TaskController manages task list state.

`.obs` used to create reactive lists.

`Obx()` used to rebuild widgets on state changes.

###  SharedPreferences

**Used to store:**

- Login state (current_user)

- Dark mode toggle

###  Navigation
- Handled using `Get.to()` and `Get.offAll()` to simplify routing and prevent manual Navigator use.

`Get.to(() => AddEditTaskScreen());`

### 📂 Folder Structure

```bash
lib/
├── controllers/         # GetX controllers
├── db/                  # SQLite helpers
├── models/              # Task model
├── screens/
│   ├── auth/            # Login, Register, Reset
│   ├── home/            # Tabs, calendar, stats, etc.
│   └── task/            # Add/Edit/Details
├── services/            # Notification & Firebase services
├── widgets/             # Reusable UI widgets
└── main.dart            # App entry point
|-- others
```


#### ✅ TODOs
 - Add real-time Firestore sync

 - Implement SQLite fallback

 - Push notifications

 - Task filtering

 - Backup/Restore to cloud

 - Theme customization
