# Avatar Feature Integration Guide

Complete guide for integrating the 3D Avatar feature from LIV App into another Flutter application.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Dependencies](#dependencies)
5. [Integration Steps](#integration-steps)
6. [Code Structure](#code-structure)
7. [Configuration](#configuration)
8. [Usage Examples](#usage-examples)
9. [API Reference](#api-reference)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The Avatar feature integrates **Ready Player Me** (RPM) avatar creation into your Flutter app. It allows users to:

- Create personalized 3D avatars using Ready Player Me's web-based creator
- Save avatars locally (GLB 3D model + PNG preview)
- Manage multiple avatars per user
- Set avatars as profile pictures
- View avatar history
- Support for user-specific storage (isolated per user)

### Key Features

- ✅ **Ready Player Me Integration**: Uses RPM's Frame API for in-app avatar creation
- ✅ **Cross-Platform**: Supports Web, Windows, Android, iOS, macOS
- ✅ **User Isolation**: Each user has their own avatar storage directory
- ✅ **Local Storage**: Avatars stored locally with PNG previews
- ✅ **Automatic Profile Avatar**: New avatars automatically set as profile picture
- ✅ **Avatar History**: View and manage all created avatars

---

## Architecture

### Core Components

1. **AvatarService** (`lib/services/avtar_service.dart`)
   - Handles avatar loading, downloading, and storage
   - Manages user-specific directories
   - Integrates with Ready Player Me API

2. **AvatarCreatorScreen** (`lib/screens/avtar_creator_screen.dart` / `lib/avtar_features/Avtar_Creator_Screen.dart`)
   - WebView wrapper for Ready Player Me creator
   - Handles avatar export events
   - Downloads and saves avatars

3. **AvatarMainScreen** (`lib/screens/avtar_main_screen.dart`)
   - Main UI for avatar management
   - Displays current avatar and history
   - Navigation to creator

4. **UserService** (`lib/services/user_service.dart`)
   - Manages selected profile avatar
   - Persists avatar selection

5. **AuthService** (`lib/services/auth_service.dart`)
   - Provides user ID for user-specific storage
   - Required for avatar isolation

6. **AppPaths** (`lib/config/paths.dart`)
   - Centralized path configuration
   - User-specific directory resolution

---

## Prerequisites

1. **Ready Player Me Account**
   - Sign up at [readyplayer.me](https://readyplayer.me)
   - No API key required for basic usage (Frame API is free)

2. **Flutter SDK**
   - Flutter 3.0.0 or higher
   - Dart 3.0.0 or higher

3. **Platform Support**
   - Web: Requires WebView support
   - Windows: Requires `webview_windows` package
   - Android/iOS: Standard WebView support
   - macOS: Standard WebView support

---

## Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  provider: ^6.1.1

  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1

  # Network
  http: ^1.5.0

  # WebView for avatar creator
  webview_flutter: ^4.4.2
  webview_windows: ^0.4.0  # Only for Windows desktop
  
  # Utilities
  url_launcher: ^6.2.2
  permission_handler: ^11.3.1  # For Android/iOS storage permissions
```

---

## Integration Steps

### Step 1: Copy Required Files

Copy these files/folders to your Flutter project:

```
your_flutter_app/
├── lib/
│   ├── services/
│   │   ├── avtar_service.dart
│   │   ├── auth_service.dart      # Required for user ID
│   │   └── user_service.dart      # Required for avatar selection
│   ├── config/
│   │   └── paths.dart
│   ├── screens/
│   │   ├── avtar_main_screen.dart
│   │   └── avtar_creator_screen.dart
│   └── avtar_features/
│       └── Avtar_Creator_Screen.dart  # Alternative implementation
```

### Step 2: Set Up Authentication Service

Your app must have an `AuthService` that provides:
- `userId` (int?) - Current logged-in user's ID
- `instance` (static getter) - Singleton instance

**Example AuthService structure:**

```dart
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  
  int? _userId;
  int? get userId => _userId;
  
  // Your authentication logic here
}
```

### Step 3: Configure Paths

Update `lib/config/paths.dart` to match your project structure:

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';

class AppPaths {
  // Change this to your server URL if needed
  static const String apiBaseUrl = 'http://localhost/YourApp/api';
  
  // Windows: Change to your desired storage location
  static const String windowsUploadsBase = r'C:\YourApp\avatars\Uploads';
  
  // Get user-specific uploads path for Windows
  static String getWindowsUploadsPath(int? userId) {
    if (userId == null) {
      throw Exception('User must be logged in');
    }
    return '$windowsUploadsBase\\user_$userId';
  }
  
  // Resolve uploads directory for current platform
  static Future<Directory> resolveUploadsDirectory() async {
    final userId = AuthService.instance.userId;
    if (userId == null) {
      throw Exception('User must be logged in');
    }
    
    if (Platform.isWindows) {
      return Directory(getWindowsUploadsPath(userId));
    }
    
    // For other platforms, use app documents directory
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/uploads/user_$userId');
  }
}
```

### Step 4: Set Up Provider (State Management)

Add `UserService` to your `MultiProvider`:

```dart
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

// In your main.dart or app initialization
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService.instance),
    ChangeNotifierProvider(create: (_) => UserService.instance),
    // ... other providers
  ],
  child: YourApp(),
)
```

### Step 5: Update UserService

Ensure `UserService` has:
- `selectAvatar(String avatarPath)` method
- `setUserId(int? userId)` method
- `selectedAvatar` getter

**Example UserService structure:**

```dart
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  
  String? _selectedAvatar;
  int? _currentUserId;
  
  String? get selectedAvatar => _selectedAvatar;
  
  void setUserId(int? userId) {
    _currentUserId = userId;
    if (userId != null) {
      _loadSavedAvatar();
    } else {
      _selectedAvatar = null;
    }
    notifyListeners();
  }
  
  void selectAvatar(String avatarPath) async {
    if (_currentUserId == null) return;
    _selectedAvatar = avatarPath;
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${_currentUserId}_selectedAvatar', avatarPath);
    notifyListeners();
  }
  
  Future<void> _loadSavedAvatar() async {
    // Load from SharedPreferences
    // Implementation similar to provided code
  }
}
```

### Step 6: Add Permissions (Android/iOS)

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save your avatar images</string>
```

---

## Code Structure

### File Overview

```
lib/
├── services/
│   ├── avtar_service.dart          # Core avatar service
│   ├── auth_service.dart           # Authentication (required)
│   └── user_service.dart           # User data management (required)
├── config/
│   └── paths.dart                  # Path configuration
├── screens/
│   ├── avtar_main_screen.dart      # Main avatar management UI
│   └── avtar_creator_screen.dart   # Avatar creator WebView screen
└── avtar_features/
    └── Avtar_Creator_Screen.dart   # Alternative creator implementation
```

### Key Classes

#### AvatarService

**Main Methods:**
- `loadSavedAvatar()` - Loads user's saved avatar
- `downloadAvatar(String url, BuildContext context)` - Downloads avatar from Ready Player Me
- `getAvatarCreatorUrl({String? initialAvatarId})` - Gets Ready Player Me creator URL
- `hasAvatar()` - Checks if user has an avatar
- `getAvatarImagePath()` - Gets current avatar image path

**Usage:**
```dart
// Load saved avatar
final avatarData = await AvatarService.loadSavedAvatar();
final pngPath = avatarData['png'];
final glbPath = avatarData['glb'];
final avatarId = avatarData['id'];

// Check if user has avatar
final hasAvatar = await AvatarService.hasAvatar();

// Get avatar image path
final imagePath = await AvatarService.getAvatarImagePath();
```

#### AvatarCreatorScreen

**Features:**
- Embeds Ready Player Me creator in WebView
- Listens for avatar export events
- Automatically downloads and saves avatar
- Shows loading/success dialogs

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AvatarCreatorScreen(
      initialAvatarId: 'existing-avatar-id', // Optional
    ),
  ),
).then((result) {
  if (result == true) {
    // Avatar was saved successfully
    // Refresh your UI
  }
});
```

---

## Configuration

### Ready Player Me URL

The avatar creator uses Ready Player Me's Frame API:

```dart
// In AvatarService
static const String _baseUrl = 'https://readyplayer.me/avatar?frameApi';
```

**To customize:**
- For editing existing avatar: `https://readyplayer.me/avatar?frameApi&avatarId={id}`
- For new avatar: `https://readyplayer.me/avatar?frameApi`

### Storage Paths

**Windows:**
```dart
// Default: C:\xampp\htdocs\Liv-App\avtars\Uploads\user_{userId}
// Change in AppPaths.windowsUploadsBase
```

**Other Platforms:**
```dart
// Default: {appDocuments}/uploads/user_{userId}
// Automatically resolved via path_provider
```

---

## Usage Examples

### Example 1: Basic Integration

```dart
import 'package:flutter/material.dart';
import 'services/avtar_service.dart';
import 'screens/avtar_creator_screen.dart';

class AvatarExample extends StatefulWidget {
  @override
  _AvatarExampleState createState() => _AvatarExampleState();
}

class _AvatarExampleState extends State<AvatarExample> {
  Future<Map<String, String?>>? _avatarFuture;
  
  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }
  
  Future<void> _loadAvatar() async {
    setState(() {
      _avatarFuture = AvatarService.loadSavedAvatar();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avatar Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display avatar
            FutureBuilder<Map<String, String?>>(
              future: _avatarFuture,
              builder: (context, snapshot) {
                final pngPath = snapshot.data?['png'];
                if (pngPath != null && File(pngPath).existsSync()) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(File(pngPath)),
                  );
                }
                return Icon(Icons.person, size: 100);
              },
            ),
            SizedBox(height: 20),
            // Create avatar button
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvatarCreatorScreen(),
                  ),
                );
                if (result == true) {
                  _loadAvatar(); // Refresh
                }
              },
              child: Text('Create Avatar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Example 2: Avatar Management Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/avtar_service.dart';
import 'services/user_service.dart';
import 'screens/avtar_main_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          // Profile avatar
          Consumer<UserService>(
            builder: (context, userService, child) {
              final avatarPath = userService.selectedAvatar;
              return CircleAvatar(
                radius: 60,
                backgroundImage: avatarPath != null
                    ? FileImage(File(avatarPath))
                    : null,
                child: avatarPath == null
                    ? Icon(Icons.person, size: 60)
                    : null,
              );
            },
          ),
          SizedBox(height: 20),
          // Navigate to avatar management
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvatarMainScreen(),
                ),
              );
            },
            child: Text('Manage Avatars'),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Check Avatar Status

```dart
Future<void> checkAvatarStatus() async {
  final hasAvatar = await AvatarService.hasAvatar();
  if (hasAvatar) {
    final avatarPath = await AvatarService.getAvatarImagePath();
    print('User has avatar: $avatarPath');
  } else {
    print('User has no avatar');
  }
}
```

---

## API Reference

### AvatarService

#### `loadSavedAvatar()`
Returns `Future<Map<String, String?>>` with:
- `'id'`: Avatar ID (String?)
- `'glb'`: GLB file path (String?)
- `'png'`: PNG preview path (String?)

#### `downloadAvatar(String url, BuildContext context)`
Downloads avatar from Ready Player Me URL and saves locally.

**Parameters:**
- `url`: Ready Player Me avatar GLB URL
- `context`: BuildContext for showing messages

#### `getAvatarCreatorUrl({String? initialAvatarId})`
Returns Ready Player Me creator URL.

**Parameters:**
- `initialAvatarId`: Optional existing avatar ID for editing

#### `hasAvatar()`
Returns `Future<bool>` indicating if user has a saved avatar.

#### `getAvatarImagePath()`
Returns `Future<String?>` with current avatar PNG path.

---

## Troubleshooting

### Issue: Avatars not saving

**Solution:**
1. Check storage permissions (Android/iOS)
2. Verify user is logged in (userId is not null)
3. Check directory creation permissions
4. Ensure `AuthService.instance.userId` returns valid ID

### Issue: WebView not loading on Windows

**Solution:**
1. Ensure `webview_windows` package is added
2. Check Windows WebView2 runtime is installed
3. Verify `webview_flutter` version compatibility

### Issue: Avatar not appearing after creation

**Solution:**
1. Refresh the screen after avatar creation
2. Check `UserService.selectAvatar()` is called
3. Verify SharedPreferences are saving correctly
4. Check file paths are correct

### Issue: "User must be logged in" error

**Solution:**
1. Ensure user is authenticated before accessing avatar features
2. Check `AuthService.instance.userId` is not null
3. Call `UserService.instance.setUserId(userId)` after login

### Issue: Avatar paths not found

**Solution:**
1. Verify `AppPaths.resolveUploadsDirectory()` returns correct path
2. Check directory exists and has write permissions
3. Ensure user-specific directory is created (`user_{userId}`)

---

## Platform-Specific Notes

### Web
- Uses standard WebView
- Opens in external browser as fallback
- JavaScript channel communication required

### Windows
- Uses `webview_windows` package
- Requires WebView2 runtime
- Message passing via `postMessage`

### Android/iOS
- Uses `webview_flutter`
- Requires storage permissions
- Standard WebView implementation

### macOS
- Uses `webview_flutter`
- Similar to iOS implementation

---

## Ready Player Me Integration Details

### Frame API

The implementation uses Ready Player Me's **Frame API** which:
- Embeds the creator in a WebView
- Listens for `v1.avatar.exported` events
- Extracts avatar URL from export event
- Downloads GLB and PNG files

### Event Listener

```javascript
window.addEventListener('message', (event) => {
  if (event.data?.source === 'readyplayerme') {
    if (event.data.eventName === 'v1.avatar.exported') {
      // Avatar URL: event.data.data.url
      // Send to Flutter via JavaScript channel
    }
  }
});
```

### Avatar URLs

- **GLB Model**: `https://models.readyplayer.me/{avatarId}.glb`
- **PNG Preview**: `https://models.readyplayer.me/{avatarId}.png`

---

## Security Considerations

1. **User Isolation**: Each user's avatars are stored in separate directories
2. **Path Validation**: Always validate file paths before use
3. **Storage Permissions**: Request permissions appropriately
4. **Error Handling**: Handle missing files gracefully

---

## Best Practices

1. **Always check user login status** before accessing avatar features
2. **Refresh UI** after avatar creation/saving
3. **Handle errors gracefully** - avatars are optional features
4. **Cache avatar images** for better performance
5. **Clean up old avatars** periodically to save storage

---

## Support

For issues or questions:
1. Check Ready Player Me documentation: [docs.readyplayer.me](https://docs.readyplayer.me)
2. Verify Flutter WebView compatibility
3. Check platform-specific WebView requirements

---

## License

This avatar feature integration guide is provided as-is. Ensure you comply with:
- Ready Player Me Terms of Service
- Flutter package licenses
- Your app's privacy policy

---

**Last Updated**: 2024
**Version**: 1.0.0

