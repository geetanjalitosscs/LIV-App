import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';

// Centralized paths for filesystem locations used by the app.
class AppPaths {
  // API base URL - change this if your server URL is different
  static const String apiBaseUrl = 'http://localhost/Liv-App/api';
  
  // Base Windows path where avatars are stored locally for this project.
  // Change this in one place if the folder moves.
  static const String windowsUploadsBase = r'C:\xampp\htdocs\Liv-App\avtars\Uploads';

  // Get the user-specific uploads path for Windows.
  // Returns path like: C:\xampp\htdocs\Liv-App\avtars\Uploads\user_{userId}
  static String getWindowsUploadsPath(int? userId) {
    if (userId == null) {
      throw Exception('User must be logged in to access uploads directory');
    }
    return '$windowsUploadsBase\\user_$userId';
  }

  // Resolve the uploads directory for the current platform and user.
  // - On Windows: uses [windowsUploadsBase]/user_{userId}
  // - Elsewhere: uses app documents directory `/uploads/user_{userId}`
  // Automatically gets the current user ID from AuthService.
  static Future<Directory> resolveUploadsDirectory() async {
    final userId = AuthService.instance.userId;
    if (userId == null) {
      throw Exception('User must be logged in to access uploads directory');
    }

    if (Platform.isWindows) {
      return Directory(getWindowsUploadsPath(userId));
    }

    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/uploads/user_$userId');
  }
}


