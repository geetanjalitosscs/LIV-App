# Firebase Setup Instructions

## 1. Firebase Project Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an Android app to your project
4. Use package name: `com.example.live_date`
5. Download the `google-services.json` file and place it in `android/app/`

## 2. Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase configuration:
   - `apiKey`: Your Firebase API key
   - `appId`: Your Firebase app ID
   - `messagingSenderId`: Your messaging sender ID
   - `projectId`: Your Firebase project ID
   - `storageBucket`: Your storage bucket

## 3. Enable Google Sign-In

1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Google as a sign-in provider
3. Add your app's SHA-1 fingerprint (for debug builds, you can get this by running `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)

## 4. Run the App

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app

## Features Implemented

- ✅ Bottom navigation redirects to ProfileScreen when profile button is clicked
- ✅ Theme service updated to make all text black in light theme
- ✅ Firebase authentication with Google Sign-In
- ✅ Android Gradle configuration for Firebase
- ✅ Google Sign-In button in login screen
- ✅ Firebase initialization in main.dart

## Notes

- The app uses the existing `google-services.json` file you provided
- Google Sign-In requires proper SHA-1 fingerprint configuration in Firebase Console
- Make sure to update the Firebase configuration values in `firebase_options.dart` with your actual project values
