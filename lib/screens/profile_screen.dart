import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/paths.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../widgets/profile_image_dialog.dart';
import '../services/auth_service.dart';
import '../services/avtar_service.dart';
import '../theme/liv_theme.dart';
import 'edit_profile_screen.dart';
import 'avtar_main_screen.dart';
import 'avtar_generation_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const ProfileScreen({super.key, this.onBackPressed});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver, RouteAware {
  Uint8List? _selectedImageBytes;
  Uint8List? _generatedAvatarBytes;
  bool _isGenerating = false;
  String? _readyPlayerMeAvatarPath;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Add post-frame callback to ensure refresh after screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshProfile();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh profile when app becomes active
      if (mounted && !_isRefreshing) {
        _refreshProfile();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change (e.g., when navigating to this tab)
    // Use a small delay to ensure the screen is fully built
    if (mounted && !_isRefreshing) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isRefreshing) {
          _refreshProfile();
        }
      });
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    print('Profile screen: didPopNext - refreshing profile');
    if (mounted && !_isRefreshing) {
      _refreshProfile();
    }
  }

  @override
  void didPushNext() {
    // Called when navigating away from this screen
    print('Profile screen: didPushNext');
  }

  Future<void> _refreshProfile({bool fromButton = false}) async {
    if (_isRefreshing && !fromButton) return; // Prevent duplicate auto-refreshes
    
    if (fromButton) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      // Refresh user data from database first
      await AuthService.instance.refreshUserData();
      
      // Then refresh avatar
      await _loadReadyPlayerMeAvatar(fromButton: fromButton);
      
      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    } finally {
      if (fromButton && mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadReadyPlayerMeAvatar({bool fromButton = false}) async {
    try {
      if (fromButton) {
        print('Profile screen: Manual refresh triggered by button');
      }
      final avatarPath = await AvatarService.getAvatarImagePath();
      
      if (avatarPath != null && File(avatarPath).existsSync()) {
        setState(() {
          _readyPlayerMeAvatarPath = avatarPath;
        });
      } else {
        setState(() {
          _readyPlayerMeAvatarPath = null;
        });
        print('No valid avatar found for profile screen');
      }
      
      // Force a rebuild to ensure UI updates
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading avatar in profile screen: $e');
      setState(() {
        _readyPlayerMeAvatarPath = null;
      });
    }
  }

  /// Get like count for current user
  Future<Map<String, int>> _getLikeCount(int? userId) async {
    if (userId == null) return {};
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_likes_count.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_ids': [userId]}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['likes'] != null) {
          final likes = Map<String, dynamic>.from(data['likes']);
          return likes.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0));
        }
      }
    } catch (e) {
      print('Error loading like count: $e');
    }
    return {};
  }

  // Helper method to get the appropriate profile image (returns null if no avatar)
  ImageProvider? _getProfileImage(UserService userService) {
    // First check if user has a selected avatar from UserService
    if (userService.selectedAvatar != null && File(userService.selectedAvatar!).existsSync()) {
      return FileImage(File(userService.selectedAvatar!));
    }
    // Then check Ready Player Me avatar
    else if (_readyPlayerMeAvatarPath != null) {
      return FileImage(File(_readyPlayerMeAvatarPath!));
    } 
    // Then check generated avatar bytes
    else if (_generatedAvatarBytes != null) {
      return MemoryImage(_generatedAvatarBytes!);
    } 
    // Then check selected image bytes
    else if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } 
    // Return null if no avatar (will show grey placeholder)
    else {
      return null;
    }
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Create 3D Avtar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToReadyPlayerMe();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        
        // Get user-specific uploads directory
        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.userId;
        if (userId == null) {
          _showErrorSnackBar('Please log in to save images');
          return;
        }
        
        final baseDir = await AppPaths.resolveUploadsDirectory();
        final userDir = Directory('${baseDir.path}${Platform.isWindows ? '\\' : '/'}user_$userId');
        if (!await userDir.exists()) {
          await userDir.create(recursive: true);
        }
        
        final String fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.png';
        final separator = Platform.isWindows ? '\\' : '/';
        final String filePath = '${userDir.path}$separator$fileName';
        final File imageFile = File(filePath);
        await imageFile.writeAsBytes(imageBytes);
        
        // Update the user service with the new avatar (this handles SharedPreferences)
        final userService = Provider.of<UserService>(context, listen: false);
        userService.selectAvatar(filePath);
        
        setState(() {
          _selectedImageBytes = imageBytes;
          _generatedAvatarBytes = null;
          _readyPlayerMeAvatarPath = null; // Clear Ready Player Me avatar
        });
        
        _showSuccessSnackBar('Profile image updated successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
  }

  // Show success popup
  void _showSuccessSnackBar(String message) {
    LivPopupMessage.showSuccess(context, message);
  }

  // Show error popup
  void _showErrorSnackBar(String message) {
    LivPopupMessage.showError(context, message);
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera(bool isFront) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isFront ? CameraDevice.front : CameraDevice.rear,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
          _generatedAvatarBytes = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo');
    }
  }

  // Navigate to avatar generation screen
  Future<void> _navigateToAvatarGeneration() async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarGenerationScreen(),
      ),
    );
    
    if (result != null) {
      setState(() {
        _generatedAvatarBytes = result;
        _selectedImageBytes = null; // Clear selected image when using generated avatar
        _readyPlayerMeAvatarPath = null; // Clear Ready Player Me avatar
      });
      _showSuccessSnackBar('Avtar updated successfully!');
    }
  }

  // Navigate to comprehensive avatar management screen
  Future<void> _navigateToReadyPlayerMe() async {
    print('Profile screen: Navigating to AvatarMainScreen');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarMainScreen(),
      ),
    );
    
    print('Profile screen: Returned from AvatarMainScreen with result: $result');
    // Always refresh when returning from avatar screen
    if (mounted && !_isRefreshing) {
      await _refreshProfile();
    }
    setState(() {
      _generatedAvatarBytes = null; // Clear AI generated avatar
      _selectedImageBytes = null; // Clear selected image
    });
  }

  // Legacy method - kept for compatibility but redirects to new system
  Future<void> _generateAvatar(bool is3D) async {
    await _navigateToAvatarGeneration();
  }

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: LivDecorations.dialogDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Logout',
                  style: LivTheme.getDialogTitle(context),
                ),
                
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Are you sure you want to logout?',
                  style: LivTheme.getDialogBody(context),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                            },
                            style: LivButtonStyles.dialogCancelButton,
                            child: Text(
                              'Cancel',
                              style: LivTheme.getDialogButton(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LivTheme.logoutGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                              Provider.of<AuthService>(context, listen: false).signOut();
                            },
                            style: LivButtonStyles.dialogLogoutButton,
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
        decoration: LivDecorations.mainAppBackground,
        ),
        leading: Builder(
          builder: (context) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Use callback to navigate to home tab, or fallback to pop
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () async {
                    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes
                    
                    setState(() {
                      _isRefreshing = true;
                    });
                    
                    // Use the comprehensive refresh method
                    await _refreshProfile(fromButton: true);
                  },
                  tooltip: 'Refresh profile',
                ),
        ],
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
          decoration: LivDecorations.mainAppBackground,
        child: Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              // Refresh avatar when screen regains focus
              print('Profile screen: Focus gained - refreshing avatar');
              _loadReadyPlayerMeAvatar();
            }
          },
          child: Consumer<UserService>(
            builder: (context, userService, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Card Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: userService.backgroundImage != null && File(userService.backgroundImage!).existsSync()
                            ? DecorationImage(
                                image: FileImage(File(userService.backgroundImage!)),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              )
                            : null,
                        color: userService.backgroundImage == null 
                            ? Color(userService.backgroundColor).withOpacity(0.2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Profile Header
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                // Refresh avatar before showing dialog
                                await _loadReadyPlayerMeAvatar();
                                final result = await ProfileImageDialog.show(context);
                                if (result != null) {
                                  switch (result) {
                                    case 'gallery':
                                      _pickImageFromGallery();
                                      break;
                                    case 'avatar':
                                      _navigateToReadyPlayerMe();
                                      break;
                                    case 'view':
                                      // Get the current profile image path using the same logic as _getProfileImage
                                      String? currentImagePath;
                                      if (userService.selectedAvatar != null && File(userService.selectedAvatar!).existsSync()) {
                                        currentImagePath = userService.selectedAvatar;
                                      } else if (_readyPlayerMeAvatarPath != null) {
                                        currentImagePath = _readyPlayerMeAvatarPath;
                                      } else {
                                        // Fallback to AvatarService for Ready Player Me avatars
                                        currentImagePath = await AvatarService.getAvatarImagePath();
                                      }
                                      FullScreenAvatarViewer.show(context, imagePath: currentImagePath);
                                      break;
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: LivTheme.glassmorphicLightBorder,
                                    child: _getProfileImage(userService) != null
                                        ? CircleAvatar(
                                            radius: 55,
                                            backgroundImage: _getProfileImage(userService)!,
                                            onBackgroundImageError: (exception, stackTrace) {
                                              // Handle error if needed
                                              print('Profile image error: $exception');
                                            },
                                          )
                                        : CircleAvatar(
                                            radius: 55,
                                            backgroundColor: Colors.grey[300],
                                            child: Icon(
                                              Icons.person,
                                              size: 55,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: LivDecorations.cameraIconContainer,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Color(0xFFE91E63),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Profile Info - Get from database (AuthService)
                          Consumer<AuthService>(
                            builder: (context, authService, child) {
                              final userData = authService.userData;
                              
                              // Get data from database only - no dummy data fallbacks
                              final displayName = userData?['full_name']?.toString().trim() ?? '';
                              final ageValue = userData?['age'] != null 
                                  ? int.tryParse(userData!['age'].toString())
                                  : null;
                              final location = userData?['location']?.toString().trim() ?? '';
                              final bio = userData?['bio']?.toString().trim() ?? '';
                              
                              return FutureBuilder<Map<String, int>>(
                                future: _getLikeCount(authService.userId),
                                builder: (context, snapshot) {
                                  final likeCount = snapshot.data?[authService.userId?.toString() ?? ''] ?? 0;
                                  
                                  return Column(
                                    children: [
                                  // Full Name from Database
                                  if (displayName.isNotEmpty)
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (displayName.isEmpty)
                                    Text(
                                      'Profile',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  // Age from Database
                                  if (ageValue != null)
                                    Text(
                                      '$ageValue years old',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  // Location from Database
                                  if (location.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          location,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 12),
                                  // Like Count
                                  if (likeCount > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (likeCount > 0) const SizedBox(height: 12),
                                  const SizedBox(height: 12),
                                  // About Section - Bio from Database
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: LivDecorations.glassmorphicLightCard,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'About Me',
                                          style: LivTheme.getGlassmorphicSubtitle(context),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          bio.isNotEmpty ? bio : 'No bio available',
                                          style: LivTheme.getGlassmorphicBodySecondary(context).copyWith(height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: LivDecorations.editProfileButton,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                        );
                                        // Refresh profile if profile was updated
                                        if (result == true && mounted && !_isRefreshing) {
                                          await _refreshProfile();
                                        }
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                                      style: LivButtonStyles.glassmorphicEditProfileButton,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: LivDecorations.avatarManagerButton,
                                    child: ElevatedButton.icon(
                                      onPressed: _navigateToReadyPlayerMe,
                                      icon: const Icon(Icons.person_outline, color: Colors.white),
                                      label: const Text('Avtar Manager', style: TextStyle(color: Colors.white, fontSize: 14)),
                                      style: LivButtonStyles.glassmorphicAvatarManagerButton,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                decoration: LivDecorations.logoutButton,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showLogoutDialog();
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  label: const Text('Logout', style: TextStyle(color: Colors.white)),
                                  style: LivButtonStyles.glassmorphicLogoutButton,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
