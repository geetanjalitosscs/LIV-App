import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Centralized paths for filesystem locations used by the app.
class AppPaths {
  /// Windows absolute path where avatars are stored locally for this project.
  /// Change this in one place if the folder moves.
  static const String windowsUploads = r'C:\xampp\htdocs\Liv-App\avtars\Uploads';

  /// Resolve the uploads directory for the current platform.
  /// - On Windows: uses [windowsUploads]
  /// - Elsewhere: uses app documents directory `/uploads`
  static Future<Directory> resolveUploadsDirectory() async {
    if (Platform.isWindows) {
      return Directory(windowsUploads);
    }

    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/uploads');
  }
}


