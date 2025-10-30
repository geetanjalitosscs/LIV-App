import '../config/paths.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../avtar_features/Avtar_Creator_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation.dart';
import '../services/avtar_service.dart';
import '../services/user_service.dart';
import '../theme/liv_theme.dart';

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
          decoration: LivDecorations.mainAppBackground,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
          title: const Text(
          'Avtar Creator',
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
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: LivDecorations.mainAppBackground,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40), // Add top spacing
              Center(
                child: SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06, vertical: cardWidth * 0.06),
                    decoration: LivDecorations.glassmorphicUltraLightCard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserService>(
                          builder: (context, userService, child) {
                            return FutureBuilder<Map<String, String?>> (
                              future: _avatarFuture,
                              builder: (context, snapshot) {
                                final pngPath = snapshot.data?['png'];
                                final bool hasValidAvatar = pngPath != null && File(pngPath).existsSync();
                                
                                // Check if user has selected a gallery image
                                final bool hasGalleryImage = userService.selectedAvatar != null && 
                                    File(userService.selectedAvatar!).existsSync();
                                
                                // Show the selected avatar (either 3D avatar or gallery image)
                                final bool shouldShowAvatar = hasValidAvatar || hasGalleryImage;
                                final String? displayImagePath = hasGalleryImage ? userService.selectedAvatar : pngPath;
                                
                                return MouseRegion(
                                  cursor: shouldShowAvatar ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (shouldShowAvatar) {
                                        final result = await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullScreenAvatarView(imagePath: displayImagePath!),
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
                                        gradient: shouldShowAvatar ? null : LivTheme.mainAppGradient,
                                        border: shouldShowAvatar ? Border.all(color: Colors.white.withOpacity(0.3), width: 3) : null,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: shouldShowAvatar
                                          ? Image.file(
                                              File(displayImagePath!),
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.person, color: Colors.white, size: iconSize),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: cardWidth * 0.06),
                        Text(
                          'Create Your 3D Avtar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFont,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: cardWidth * 0.02),
                        Text(
                          'Build a personalized 3D avtar',
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
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LivTheme.mainAppGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: LivTheme.primaryPink.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
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
                                         // Set the newly created avatar as profile avatar
                                         final userService = Provider.of<UserService>(context, listen: false);
                                         final newAvatarData = await _loadSavedAvatar();
                                         if (newAvatarData['png'] != null) {
                                           userService.selectAvatar(newAvatarData['png']!);
                                         }
                                         
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
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text('Create Avtar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
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
                    decoration: LivDecorations.glassmorphicUltraLightCard,
                     child: Text(
                       'No other avtars found. Create more avtars to see them here!',
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
    );
  }

  Future<void> _loadAllAvatars() async {
    try {
      final windowsUploads = AppPaths.windowsUploads;
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
      
      // Check if user has selected a gallery image
      final userService = Provider.of<UserService>(context, listen: false);
      final bool hasGalleryImage = userService.selectedAvatar != null && 
          File(userService.selectedAvatar!).existsSync();
      
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
        
        // Filter out the currently selected profile avatar only if no gallery image is selected
        final filteredAvatars = avatarList.where((avatar) {
          // If gallery image is selected, include all avatars in the gallery
          // If no gallery image is selected, exclude the current profile avatar
          return hasGalleryImage || avatar['id'] != currentAvatarId;
        }).toList();
        
        print('Setting ${filteredAvatars.length} avatars (${hasGalleryImage ? 'including' : 'excluding'} current profile avatar)');
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
      decoration: LivDecorations.glassmorphicUltraLightCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 Text(
                   'Your Other Avtars',
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
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () async {
                                    // Show full screen view first
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenAvatarView(imagePath: avatar['png']!),
                                      ),
                                    );
                                    
                                    // If user confirmed selection from full screen
                                    if (result == true) {
                                      // Set this avatar as the profile avatar using UserService
                                      final userService = Provider.of<UserService>(context, listen: false);
                                      userService.selectAvatar(avatar['png']!);
                                      
                                      // Refresh the avatar data
                                      setState(() {
                                        _avatarFuture = _loadSavedAvatar();
                                      });
                                      await _loadAllAvatars(); // Also refresh the gallery
                                      
                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Avtar selected as profile picture!'),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
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
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Avtar ${_allAvatars.length - index}',
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
      print('Setting avatar as profile: $imagePath');
      
      // Use UserService to set the avatar (this handles all SharedPreferences updates)
      final userService = Provider.of<UserService>(context, listen: false);
      userService.selectAvatar(imagePath);
      
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
          decoration: LivDecorations.mainAppBackground,
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
