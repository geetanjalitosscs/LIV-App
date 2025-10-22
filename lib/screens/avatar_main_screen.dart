import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../avatar_features/Avatar_Creator_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation.dart';
import '../services/avatar_service.dart';

class AvatarMainScreen extends StatefulWidget {
  const AvatarMainScreen({super.key});

  @override
  State<AvatarMainScreen> createState() => _AvatarMainScreenState();
}

class _AvatarMainScreenState extends State<AvatarMainScreen> {
  Future<Map<String, String?>>? _avatarFuture;
  List<Map<String, String?>> _allAvatars = [];
  int _currentIndex = 4; // Profile tab is active
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadSavedAvatar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllAvatars();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh avatar when returning to this screen
    setState(() {
      _avatarFuture = _loadSavedAvatar();
    });
    _loadAllAvatars();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFFE91E63)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Avatar Creator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                _avatarFuture = _loadSavedAvatar();
              });
              await _loadAllAvatars();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF42A5F5), Color(0xFFE91E63)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
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
                                onTap: () async {
                                  if (hasValidAvatar) {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenAvatarView(imagePath: pngPath!),
                                      ),
                                    );
                                    if (result == true) {
                                      // Refresh the avatar data
                                      setState(() {
                                        _avatarFuture = _loadSavedAvatar();
                                      });
                                    }
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
                                  MaterialPageRoute(builder: (context) => const AvatarCreatorScreen()),
                                );
                                       if (result == true && mounted) {
                                         setState(() {
                                           _avatarFuture = _loadSavedAvatar();
                                         });
                                         await _loadAllAvatars(); // Reload all avatars
                                         // Return true to parent screen to indicate success
                                         Navigator.of(context).pop(true);
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
              // Avatar Gallery Section
              if (_allAvatars.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAvatarGallery(),
                ),
              ] else ...[
                // Debug: Show when no avatars
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                     child: Text(
                       'No other avatars found. Create more avatars to see them here!',
                       style: TextStyle(
                         color: Colors.white.withOpacity(0.75),
                         fontSize: 16,
                       ),
                       textAlign: TextAlign.center,
                     ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation based on index
          switch (index) {
            case 0: // Home
              Navigator.of(context).pop();
              break;
            case 1: // Friends
              // Navigate to friends screen
              break;
            case 2: // Messages
              // Navigate to messages screen
              break;
            case 3: // Discover
              // Navigate to discover screen
              break;
            case 4: // Profile
              // Already on profile/avatar screen
              break;
          }
        },
      ),
    );
  }

  Future<void> _loadAllAvatars() async {
    try {
      final windowsUploads = r'C:\xampp\htdocs\Liv-App\Uploads';
      final uploadsDir = Directory(windowsUploads);
      
      print('Loading avatars from: $windowsUploads');
      
      if (!uploadsDir.existsSync()) {
        print('Uploads directory does not exist');
        setState(() {
          _allAvatars = [];
        });
        return;
      }
      
      // Get the currently selected avatar ID
      String? currentAvatarId;
      try {
        final currentAvatar = await _avatarFuture;
        if (currentAvatar != null && currentAvatar['id'] != null) {
          currentAvatarId = currentAvatar['id'];
          print('Current profile avatar ID: $currentAvatarId');
        }
      } catch (e) {
        print('Error getting current avatar: $e');
      }
      
      final pngFiles = uploadsDir
          .listSync()
          .where((file) => file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      print('Found ${pngFiles.length} PNG files');
      
      if (pngFiles.isNotEmpty) {
        pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        final avatarList = pngFiles.map((file) {
          final fileName = file.path.split('\\').last;
          final avatarId = fileName.replaceAll('.png', '');
          final glbPath = '$windowsUploads\\$avatarId.glb';
          
          print('Processing avatar: $avatarId');
          
          return {
            'id': avatarId,
            'glb': File(glbPath).existsSync() ? glbPath : null,
            'png': file.path,
            'date': file.lastModifiedSync().toString(),
          };
        }).toList();
        
        // Filter out the currently selected profile avatar
        final filteredAvatars = avatarList.where((avatar) {
          return avatar['id'] != currentAvatarId;
        }).toList();
        
        print('Setting ${filteredAvatars.length} avatars (excluding current profile avatar)');
        setState(() {
          _allAvatars = filteredAvatars;
        });
      } else {
        print('No PNG files found');
        setState(() {
          _allAvatars = [];
        });
      }
    } catch (e) {
      print('Error loading all avatars: $e');
      setState(() {
        _allAvatars = [];
      });
    }
  }

  Widget _buildAvatarGallery() {
    print('Building avatar gallery with ${_allAvatars.length} avatars');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 Text(
                   'Your Other Avatars',
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.w700,
                     color: Colors.white,
                   ),
                 ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Left arrow
              if (_allAvatars.length > 3)
                IconButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.offset - 120,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.white.withOpacity(0.8),
                    size: 32,
                  ),
                ),
              // Gallery
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: _allAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _allAvatars[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenAvatarView(imagePath: avatar['png']!),
                                    ),
                                  );
                                  if (result == true) {
                                    // Refresh the avatar data
                                    setState(() {
                                      _avatarFuture = _loadSavedAvatar();
                                    });
                                    await _loadAllAvatars(); // Also refresh the gallery
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.file(
                                    File(avatar['png']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Avatar ${_allAvatars.length - index}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Right arrow
              if (_allAvatars.length > 3)
                IconButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.offset + 120,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.8),
                    size: 32,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

  Future<Map<String, String?>> _loadSavedAvatar() async {
    try {
      // Use AvatarService which properly checks SharedPreferences first
      return await AvatarService.loadSavedAvatar();
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

  Future<void> _saveAsProfileAvatar(BuildContext context) async {
    try {
      // Extract avatar ID from the image path
      final fileName = imagePath.split('\\').last;
      final avatarId = fileName.replaceAll('.png', '');
      
      print('Setting avatar as profile: $avatarId');
      print('Avatar path: $imagePath');
      
      // Update SharedPreferences to set this as the current profile avatar
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastAvatarId', avatarId);
      await prefs.setString('lastAvatarPngPath', imagePath);
      
      // Also update the GLB path if it exists
      final glbPath = imagePath.replaceAll('.png', '.glb');
      if (File(glbPath).existsSync()) {
        await prefs.setString('lastAvatarGlbPath', glbPath);
        print('GLB path also updated: $glbPath');
      }
      
      // Force a refresh by clearing any cached data
      await prefs.remove('cachedAvatarData');
      
      print('Profile avatar updated successfully');
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar set as profile photo successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back to avatar screen with success flag
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Error setting avatar as profile: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set avatar as profile photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFFE91E63)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Avatar View',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _saveAsProfileAvatar(context),
              child: const Text(
                'Save Avatar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
