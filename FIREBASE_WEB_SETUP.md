# Firebase Web Setup Instructions

## Step 1: Add Web App to Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `liv-health-e1ee4`
3. Click on the gear icon (⚙️) next to "Project Overview"
4. Select "Project settings"
5. Scroll down to "Your apps" section
6. Click on the web icon (`</>`) to add a web app
7. Register your app with nickname: "Live Date Web"
8. Check "Also set up Firebase Hosting" (optional)
9. Click "Register app"
10. Copy the `firebaseConfig` object that appears

## Step 2: Enable Google Sign-In

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Click on "Google" provider
3. Toggle "Enable" to ON
4. Add your project's support email
5. Click "Save"

## Step 3: Update Web App ID

After adding the web app, you'll get a config like this:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyB0BmIFloTGEzBBCNXdd-p6_TNiof14hX0",
  authDomain: "liv-health-e1ee4.firebaseapp.com",
  projectId: "liv-health-e1ee4",
  storageBucket: "liv-health-e1ee4.firebasestorage.app",
  messagingSenderId: "841660884449",
  appId: "1:841660884449:web:YOUR_ACTUAL_WEB_APP_ID" // This will be different
};
```

## Step 4: Update the Code

1. Replace `your-web-app-id` in `lib/firebase_options.dart` with your actual web app ID
2. Replace `your-web-app-id` in `web/index.html` with your actual web app ID

## Step 5: Test the App

Run the app and try Google Sign-In. It should now work with your Firebase project!

## Current Status

✅ Firebase project configured with your credentials
✅ Google Sign-In enabled in code
✅ Android configuration ready
⏳ Web app needs to be added to Firebase Console
⏳ Web app ID needs to be updated in code
