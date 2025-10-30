import 'dart:io' show Platform;
import '../config/paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Avtar_Creator_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(const MyAvatarApp());
}

class MyAvatarApp extends StatelessWidget {
  const MyAvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Avatar App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, String?>>? _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadSavedAvatar();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double maxCardWidth = size.width * 0.92;
    final double cardWidth = maxCardWidth.clamp(280.0, 420.0);
    final double iconSize = cardWidth * 0.11;
    final double titleFont = (cardWidth * 0.07).clamp(18.0, 28.0);
    final double bodyFont = (cardWidth * 0.035).clamp(12.0, 16.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B1220)],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06, vertical: cardWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<Map<String, String?>> (
                    future: _avatarFuture,
                    builder: (context, snapshot) {
                      final pngPath = snapshot.data?['png'];
                      final bool hasValidAvatar = pngPath != null && File(pngPath).existsSync();
                      
                      return MouseRegion(
                        cursor: hasValidAvatar ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: () {
                            if (hasValidAvatar) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenAvatarView(imagePath: pngPath!),
                                ),
                              );
                            }
                          },
                        child: Container(
                          width: iconSize * 1.8,
                          height: iconSize * 1.8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasValidAvatar ? null : const LinearGradient(
                              colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                            ),
                            border: hasValidAvatar ? Border.all(color: Colors.white.withOpacity(0.3), width: 3) : null,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasValidAvatar
                              ? Image.file(
                                  File(pngPath),
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person, color: Colors.white, size: iconSize),
                        ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: cardWidth * 0.06),
                  Text(
                    'Create Your 3D Avatar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: cardWidth * 0.02),
                  Text(
                    'Build a personalized 3D avatar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodyFont,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: cardWidth * 0.06),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Open in-app creator on all native platforms; use browser on Web
                        final bool openInApp = !kIsWeb && (
                          Platform.isAndroid ||
                          Platform.isIOS ||
                          Platform.isMacOS ||
                          Platform.isWindows
                        );
                        if (openInApp) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AvtarCreatorScreen()),
                          );
                          if (result == true && mounted) {
                            setState(() {
                              _avatarFuture = _loadSavedAvatar();
                            });
                          }
                        } else {
                          final uri = Uri.parse('https://readyplayer.me/avatar');
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 8,
                      ),
                      child: const Text('Create Avatar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<Map<String, String?>> _loadSavedAvatar() async {
  try {
    // Scan the uploads folder for the most recent avatar
    final windowsUploads = AppPaths.windowsUploads;
    final uploadsDir = Directory(windowsUploads);
    
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
    final glbPath = '$windowsUploads\\$avatarId.glb';
    
    print('Found latest avatar: $avatarId');
    return {
      'id': avatarId,
      'glb': File(glbPath).existsSync() ? glbPath : null,
      'png': latestPng.path,
    };
  } catch (e) {
    print('Error in _loadSavedAvatar: $e');
    return {'id': null, 'glb': null, 'png': null};
  }
}

class FullScreenAvatarView extends StatelessWidget {
  final String imagePath;

  const FullScreenAvatarView({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Avatar View',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
