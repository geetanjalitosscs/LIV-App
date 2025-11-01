import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as winwv;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/paths.dart';
import 'auth_service.dart';
import 'user_service.dart';

class AvatarService {
  static const String _baseUrl = 'https://readyplayer.me/avatar?frameApi';

  /// Get user-specific key for SharedPreferences
  static String _getKey(String key) {
    final userId = AuthService.instance.userId;
    if (userId == null) return key;
    return 'user_${userId}_$key';
  }

  /// Get user-specific uploads directory
  static Future<Directory> _getUserUploadsDirectory() async {
    // AppPaths.resolveUploadsDirectory() already returns the user-specific directory
    // (e.g., C:\xampp\htdocs\Liv-App\avtars\Uploads\user_{userId})
    // So we just return it directly without adding user_$userId again
    final baseDir = await AppPaths.resolveUploadsDirectory();
    
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    
    return baseDir;
  }

  /// Load saved avatar from local storage
  static Future<Map<String, String?>> loadSavedAvatar() async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        return {'id': null, 'glb': null, 'png': null};
      }

      // First check SharedPreferences for the selected profile avatar
      final prefs = await SharedPreferences.getInstance();
      final selectedAvatarId = prefs.getString(_getKey('lastAvatarId'));
      final selectedPngPath = prefs.getString(_getKey('lastAvatarPngPath'));
      final selectedGlbPath = prefs.getString(_getKey('lastAvatarGlbPath'));
      
      if (selectedAvatarId != null && selectedPngPath != null && File(selectedPngPath).existsSync()) {
        // print('Using selected profile avatar: $selectedAvatarId'); // Removed to prevent log spam
        return {
          'id': selectedAvatarId,
          'glb': selectedGlbPath != null && File(selectedGlbPath).existsSync() ? selectedGlbPath : null,
          'png': selectedPngPath,
        };
      }
      
      // Fallback: Get all PNG files from user directory and find the most recent one
      final uploadsDir = await _getUserUploadsDirectory();
      
      if (!uploadsDir.existsSync()) {
        print('User uploads directory does not exist for user $userId');
        return {'id': null, 'glb': null, 'png': null};
      }
      
      // Get all PNG files and find the most recent one
      final pngFiles = uploadsDir
          .listSync()
          .where((file) => file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      if (pngFiles.isEmpty) {
        print('No PNG files found in user uploads folder for user $userId');
        return {'id': null, 'glb': null, 'png': null};
      }
      
      // Sort by modification time (most recent first)
      pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final latestPng = pngFiles.first;
      
      // Extract avatar ID from filename
      final fileName = latestPng.path.split(Platform.isWindows ? '\\' : '/').last;
      final avatarId = fileName.replaceAll('.png', '');
      final separator = Platform.isWindows ? '\\' : '/';
      final glbPath = '${uploadsDir.path}$separator$avatarId.glb';
      
      // print('Found latest avatar: $avatarId'); // Removed to prevent log spam
      return {
        'id': avatarId,
        'glb': File(glbPath).existsSync() ? glbPath : null,
        'png': latestPng.path,
      };
    } catch (e) {
      print('Error in loadSavedAvatar: $e');
      return {'id': null, 'glb': null, 'png': null};
    }
  }

  /// Download avatar from Ready Player Me URL
  static Future<void> downloadAvatar(String url, BuildContext context) async {
    try {
      if (kIsWeb) {
        // On web, trigger browser download/open
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar opened in a new tab for download")),
        );
        return;
      }

      // Request storage permission only for non-web platforms
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        if (!await Permission.storage.request().isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Storage permission denied")),
            );
          }
          return;
        }
      }

      // Extract avatar ID from RPM url .../{id}.glb
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final String fileName = segments.isNotEmpty ? segments.last : 'avatar.glb';
      final String avatarId = fileName.replaceAll('.glb', '');
      
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw Exception('User must be logged in to download avatars');
      }

      print('Downloading avatar from: $url');
      print('Avatar ID: $avatarId for user: $userId');

      final uploads = await _getUserUploadsDirectory();
      
      print('Saving to user directory: ${uploads.path}');
      if (!await uploads.exists()) {
        await uploads.create(recursive: true);
      }

      final separator = Platform.isWindows ? '\\' : '/';

      // Download GLB
      final glbResp = await http.get(Uri.parse(url));
      final glbPath = '${uploads.path}$separator$fileName';
      await File(glbPath).writeAsBytes(glbResp.bodyBytes);

      // Try to download PNG preview using the same id
      final pngUrl = Uri.parse('https://models.readyplayer.me/$avatarId.png');
      String? pngPath;
      try {
        final pngResp = await http.get(pngUrl);
        if (pngResp.statusCode == 200) {
          pngPath = '${uploads.path}$separator$avatarId.png';
          await File(pngPath).writeAsBytes(pngResp.bodyBytes);
        }
      } catch (_) {}

      // Persist references with user-specific keys
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getKey('lastAvatarId'), avatarId);
      await prefs.setString(_getKey('lastAvatarGlbPath'), glbPath);
      if (pngPath != null) {
        await prefs.setString(_getKey('lastAvatarPngPath'), pngPath);
      }

      // Automatically set as profile avatar
      if (pngPath != null) {
        UserService.instance.selectAvatar(pngPath);
        print('Newly created avatar set as profile avatar: $pngPath');
      }

      if (!context.mounted) return;
      
      print('Avatar saved successfully! GLB: $glbPath, PNG: $pngPath');
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save avatar: $e')),
      );
    }
  }

  /// Get avatar creator URL
  static String getAvatarCreatorUrl({String? initialAvatarId}) {
    return initialAvatarId == null
        ? _baseUrl
        : '$_baseUrl&avatarId=${Uri.encodeComponent(initialAvatarId)}';
  }

  /// Check if avatar exists locally
  static Future<bool> hasAvatar() async {
    final avatarData = await loadSavedAvatar();
    return avatarData['png'] != null && File(avatarData['png']!).existsSync();
  }

  /// Get avatar image path
  static Future<String?> getAvatarImagePath() async {
    final avatarData = await loadSavedAvatar();
    return avatarData['png'];
  }
}
