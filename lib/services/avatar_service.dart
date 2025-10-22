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

class AvatarService {
  static const String _baseUrl = 'https://readyplayer.me/avatar?frameApi';
  static const String _uploadsPath = r'C:\xampp\htdocs\Liv-App\Uploads';

  /// Load saved avatar from local storage
  static Future<Map<String, String?>> loadSavedAvatar() async {
    try {
      final uploadsDir = Directory(_uploadsPath);
      
      if (!uploadsDir.existsSync()) {
        print('Uploads directory does not exist');
        return {'id': null, 'glb': null, 'png': null};
      }
      
      // Get all PNG files and find the most recent one
      final pngFiles = uploadsDir
          .listSync()
          .where((file) => file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      if (pngFiles.isEmpty) {
        print('No PNG files found in uploads folder');
        return {'id': null, 'glb': null, 'png': null};
      }
      
      // Sort by modification time (most recent first)
      pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final latestPng = pngFiles.first;
      
      // Extract avatar ID from filename
      final fileName = latestPng.path.split('\\').last;
      final avatarId = fileName.replaceAll('.png', '');
      final glbPath = '$_uploadsPath\\$avatarId.glb';
      
      print('Found latest avatar: $avatarId');
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
      
      print('Downloading avatar from: $url');
      print('Avatar ID: $avatarId');

      Directory uploads;
      if (Platform.isWindows) {
        // Save to requested absolute directory on Windows
        uploads = Directory(_uploadsPath);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        uploads = Directory('${dir.path}/uploads');
      }
      
      print('Saving to directory: ${uploads.path}');
      if (!await uploads.exists()) {
        await uploads.create(recursive: true);
      }

      // Download GLB
      final glbResp = await http.get(Uri.parse(url));
      final glbPath = '${uploads.path}/$fileName';
      await File(glbPath).writeAsBytes(glbResp.bodyBytes);

      // Try to download PNG preview using the same id
      final pngUrl = Uri.parse('https://models.readyplayer.me/$avatarId.png');
      String? pngPath;
      try {
        final pngResp = await http.get(pngUrl);
        if (pngResp.statusCode == 200) {
          pngPath = '${uploads.path}/$avatarId.png';
          await File(pngPath).writeAsBytes(pngResp.bodyBytes);
        }
      } catch (_) {}

      // Persist references
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastAvatarId', avatarId);
      await prefs.setString('lastAvatarGlbPath', glbPath);
      if (pngPath != null) {
        await prefs.setString('lastAvatarPngPath', pngPath);
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
