import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../services/avatar_generator_service.dart';
import '../services/avatar_service.dart';
import 'avatar_setup_screen.dart';
import 'avatar_generation_screen.dart';
import 'avatar_creator_screen.dart';
import 'avatar_main_screen.dart';
import 'avatar_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver, RouteAware {
  Uint8List? _selectedImageBytes;
  Uint8List? _generatedAvatarBytes;
  bool _isGenerating = false;
  final AvatarGeneratorService _avatarService = AvatarGeneratorService.instance;
  String? _readyPlayerMeAvatarPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReadyPlayerMeAvatar();
    
    // Add post-frame callback to ensure refresh after screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReadyPlayerMeAvatar();
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
      // Refresh avatar when app becomes active
      _loadReadyPlayerMeAvatar();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh avatar when returning to this screen
    _loadReadyPlayerMeAvatar();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    print('Profile screen: didPopNext - refreshing avatar');
    _loadReadyPlayerMeAvatar();
  }

  @override
  void didPushNext() {
    // Called when navigating away from this screen
    print('Profile screen: didPushNext');
  }

  Future<void> _loadReadyPlayerMeAvatar() async {
    try {
      print('Profile screen: Starting avatar refresh...');
      final avatarPath = await AvatarService.getAvatarImagePath();
      print('Profile screen loading avatar: $avatarPath');
      
      if (avatarPath != null && File(avatarPath).existsSync()) {
        setState(() {
          _readyPlayerMeAvatarPath = avatarPath;
        });
        print('Profile screen avatar updated successfully: $avatarPath');
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

  // Helper method to get the appropriate profile image
  ImageProvider _getProfileImage(UserService userService) {
    if (_readyPlayerMeAvatarPath != null) {
      return FileImage(File(_readyPlayerMeAvatarPath!));
    } else if (_generatedAvatarBytes != null) {
      return MemoryImage(_generatedAvatarBytes!);
    } else if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else {
      // Use a default placeholder since we're removing local avatars
      return const AssetImage('assets/images/pngtree-google.png');
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
                title: const Text('Create 3D Avatar'),
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
        setState(() {
          _selectedImageBytes = imageBytes;
          _generatedAvatarBytes = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
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
      _showSuccessSnackBar('Avatar updated successfully!');
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
    if (result == true) {
      // Reload the Ready Player Me avatar
      print('Profile screen: Avatar was updated, refreshing...');
      await _loadReadyPlayerMeAvatar();
      setState(() {
        _generatedAvatarBytes = null; // Clear AI generated avatar
        _selectedImageBytes = null; // Clear selected image
      });
      _showSuccessSnackBar('3D Avatar updated successfully!');
    } else {
      // Even if result is false, refresh to ensure consistency
      print('Profile screen: No avatar update, but refreshing anyway...');
      await _loadReadyPlayerMeAvatar();
    }
  }

  // Legacy method - kept for compatibility but redirects to new system
  Future<void> _generateAvatar(bool is3D) async {
    await _navigateToAvatarGeneration();
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
      ),
      body: Focus(
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
                  // Profile Header
                  GestureDetector(
                    onTap: () async {
                      // Refresh avatar before showing dialog
                      await _loadReadyPlayerMeAvatar();
                      _showImageSourceDialog();
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _getProfileImage(userService),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle error if needed
                            print('Profile image error: $exception');
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFFed4273),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Loading indicator for avatar generation
                if (_isGenerating)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFed4273)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generating avatar...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Profile Info
                Text(
                  userService.displayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black87
                            : Colors.white,
                      ),
                ),
                Text(
                  '${userService.age} years old',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black87
                            : Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userService.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // About Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[300]!
                          : const Color(0xFF404040),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Me',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userService.bio,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AvatarSetupScreen()),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFed4273),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _navigateToReadyPlayerMe,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Avatar Manager'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
