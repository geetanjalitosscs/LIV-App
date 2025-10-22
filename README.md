# LIV - Friendship Platform

A Flutter application that helps you connect with friends and build meaningful relationships.

## Features

- **Google Sign-In Authentication** - Secure login with Firebase Auth
- **Health Data Integration** - Track steps, sleep, calories, and heart rate
- **AI Coach** - Personalized health advice based on your data
- **Social Feed** - Share your experiences and connect with friends
- **Avatar Setup** - Customize your digital twin
- **Push Notifications** - Stay motivated with timely reminders
- **Welcome Back Screen** - Special greeting after 48+ hours of inactivity

## Project Structure

```
flutter_liv/
├─ lib/
│   ├─ main.dart                 # Entry point, Firebase init, routing
│   ├─ firebase_options.dart     # Generated config from flutterfire CLI
│   ├─ config.dart               # App config (demoMode, URLs, flags)
│   ├─ services/                 # Auth, Health, Messaging, etc.
│   │   ├─ auth_service.dart
│   │   ├─ health_service.dart
│   │   ├─ ai_coach_service.dart
│   │   └─ messaging_service.dart
│   ├─ screens/                  # All app screens
│   │   ├─ login_screen.dart
│   │   ├─ home_screen.dart
│   │   ├─ avatar_setup_screen.dart
│   │   ├─ coach_screen.dart
│   │   ├─ feed_screen.dart
│   │   ├─ feedback_screen.dart
│   │   └─ welcome_back_screen.dart
│   └─ widgets/                  # Reusable UI widgets
│       └─ typing_text.dart
└─ pubspec.yaml                  # Dependencies
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project

### 2. Configure Firebase

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

3. This will generate the `firebase_options.dart` file with your project configuration.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

### 5. Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (macOS only):**
```bash
flutter build ios --release
```

## Firebase Setup

### Required Firebase Services

1. **Authentication**
   - Enable Google Sign-In provider
   - Configure OAuth consent screen

2. **Firestore Database**
   - Create collections: `users`, `posts`, `feedback`
   - Set up security rules

3. **Firebase Storage**
   - Create bucket for avatar images
   - Set up security rules

4. **Firebase Messaging**
   - Configure for push notifications

### Firestore Collections

- **users/{uid}** - User profile data, FCM tokens
- **posts/{id}** - Community feed posts
- **feedback/{id}** - User feedback and ratings

## Key Features Implementation

### Authentication Flow
- Google Sign-In integration
- User data stored in Firestore
- FCM token management

### Health Data
- Google Fit / Apple Health integration
- Real-time health metrics
- Weekly and daily summaries

### AI Coach
- Rule-based advice system
- Personalized recommendations
- Motivational quotes and tips

### Social Features
- Community feed with posts
- Like and comment functionality
- User profiles and avatars

## Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `firebase_messaging` - Push notifications
- `google_sign_in` - Google authentication
- `health` - Health data access
- `flutter_animate` - Animations
- `provider` - State management

## Development Notes

- The app uses demo mode by default (configurable in `config.dart`)
- Health permissions are requested on first use
- Avatar images are stored in Firebase Storage
- Push notifications require proper Firebase configuration
- Welcome back screen triggers after 48 hours of inactivity

## Troubleshooting

1. **Firebase configuration issues**: Ensure `firebase_options.dart` is properly generated
2. **Health data not loading**: Check device permissions and health app setup
3. **Google Sign-In fails**: Verify OAuth configuration in Firebase Console
4. **Build errors**: Run `flutter clean` and `flutter pub get`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
