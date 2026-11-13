# 📝 Flutter Todo & Task Management App

A modern, responsive, and feature-rich Task Management mobile application built with **Flutter** and **Firebase**. The app delivers a clean, intuitive user experience designed around Material Design 3 principles, featuring user authentication, real-time Cloud Firestore synchronization, priority and status filtering, date-based task sorting, and a calendar agenda view.

---

## 📱 Features

### 🔐 User Authentication (Firebase Auth)
- **User Registration & Login**: Secure email and password authentication using Firebase Authentication.
- **Form Validation & Error Handling**: Real-time input validation and user-friendly error messages for invalid credentials, weak passwords, and existing accounts.
- **Password Reset**: Self-service password recovery instructions via email.
- **Session Persistence**: Automatic login detection on the Splash screen for returning users.
- **User Profile & Logout**: Accessible account overview with task statistics and secure logout functionality.

### 📋 Task Management (Full CRUD)
- **Create Tasks**: Add tasks with Title, Description, Due Date (via interactive calendar picker), and Priority (`Low`, `Medium`, `High`).
- **View Tasks**: Real-time stream updates directly from Cloud Firestore with detailed modal bottom sheets.
- **Edit Tasks**: Seamlessly update title, description, due date, and priority for existing tasks.
- **Delete Tasks**: Safe deletion workflow with confirmation dialogs.
- **Completion Toggle**: One-tap circular checkbox to toggle complete/incomplete status with animated strikethrough styling.

### 🔍 Task Filtering, Sorting & Search
- **Status Filter**: Easily filter between `All`, `Incomplete` (Pending), and `Completed` tasks with real-time counters.
- **Priority Filter**: Filter tasks by priority levels (`High`, `Medium`, `Low`).
- **Due Date Sorting**: All tasks are strictly sorted by due date (**earliest to latest**).
- **Search Bar**: Real-time keyword filtering across task titles and descriptions.
- **Section Grouping**: Automatically groups tasks into `Today`, `Tomorrow`, `This Week`, and `Later / Upcoming`.
- **Calendar Agenda View**: Interactive monthly calendar to browse tasks scheduled for any selected date.

### 🎨 Clean UI & Theme Consistency
- **Material 3 Design**: Consistent typography, card elevations, rounded borders (14–17px), and subtle shadows.
- **Cross-Platform Optimization**: Pixel-perfect spacing, padding, and layout scaling for both Android and iOS devices.
- **Color Palette**:
  - **Primary Purple**: `#625FF2`
  - **Secondary Purple**: `#8988F5`
  - **Background**: `#F7F7FA`
  - **Dark Text**: `#263653`
  - **Priority High**: `#E47777` (Red)
  - **Priority Medium**: `#E7A844` (Orange/Amber)
  - **Priority Low**: `#62B98A` (Green)

---

## 🛠️ Tech Stack & Packages

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter** | SDK ^3.12.0 | Cross-platform framework |
| **firebase_core** | `^5.1.0` | Firebase initialization & platform options |
| **firebase_auth** | `^7.0.1` | User registration, login, and session handling |
| **cloud_firestore** | `^7.1.0` | Real-time NoSQL cloud database |
| **provider** | `^6.1.5+1` | Reactive state management & dependency injection |
| **go_router** | `^17.5.0` | Declarative routing & deep linking |
| **intl** | `^0.20.3` | Date formatting and localized date handling |
| **cupertino_icons** | `^1.0.8` | iOS-styled iconography |

---

## 📁 Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Centralized color palette
│   ├── routes/
│   │   └── app_router.dart          # GoRouter route declarations
│   └── theme/
│       └── app_theme.dart           # Material 3 light theme definition
├── models/
│   └── Task_model.dart              # TaskModel entity & Firestore serialization
├── services/
│   ├── auth_service.dart            # Firebase Authentication operations & error mapping
│   └── task_service.dart            # Cloud Firestore CRUD operations
├── providers/
│   ├── auth_provider.dart           # Auth state management
│   └── task_provider.dart           # Task state, filtering, sorting & search state
├── components/
│   ├── CheckIllustration.dart       # Custom brand vector illustration
│   ├── custom_text_field.dart       # Reusable styled text input field
│   ├── social_button.dart           # Social sign-in button UI
│   ├── task_card.dart               # Task card with completion toggle & popup menu
│   ├── task_date_picker.dart        # Custom bottom-sheet date picker
│   ├── task_form_field.dart         # Form text input component
│   ├── task_header.dart             # Gradient header, search bar & user profile modal
│   ├── task_priority_selector.dart  # Priority selector chips (Low, Medium, High)
│   └── task_submit_button.dart      # Action button with loading state
├── Screens/
│   ├── splash_screen.dart           # Splash screen with auto-login check
│   ├── login_screen.dart            # User sign-in screen
│   ├── Signup_screen.dart           # User registration screen
│   ├── home_screen.dart             # Bottom navigation container
│   ├── task_list_screen.dart        # Main dashboard with filters & sections
│   ├── all_tasks_screen.dart        # Full section task list with filters
│   ├── calendar_tasks_screen.dart   # Interactive date agenda view
│   └── add_task_screen.dart         # Create & Edit task screen
├── firebase_options.dart            # FlutterFire platform configuration
└── main.dart                        # Application entry point & MultiProvider setup
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (version 3.12.0 or higher).
- Android Studio or Xcode for device emulation / testing.
- A Firebase project with **Authentication** and **Cloud Firestore** enabled.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd todo
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Place your `google-services.json` in `android/app/`.
   - Place your `GoogleService-Info.plist` in `ios/Runner/`.
   - `lib/firebase_options.dart` is pre-configured with default settings for the project.

4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🔒 Firestore Data Structure & Security Rules

### Data Hierarchy
Tasks are stored within a user-scoped subcollection for maximum data isolation and efficiency:
```
users/
  └── {userId}/
        └── tasks/
              └── {taskId}
                    ├── title: String
                    ├── description: String
                    ├── dueDate: Timestamp
                    ├── priority: String ("Low" | "Medium" | "High")
                    ├── isCompleted: Boolean
                    ├── createdAt: Timestamp
                    └── userId: String
```

### Recommended Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Running Tests

To run the unit tests for the TaskModel and calculation logic:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
