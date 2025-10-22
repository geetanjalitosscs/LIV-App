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

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _selectedImageBytes;
  Uint8List? _generatedAvatarBytes;
  bool _isGenerating = false;
  final AvatarGeneratorService _avatarService = AvatarGeneratorService.instance;
  String? _readyPlayerMeAvatarPath;

  @override
  void initState() {
    super.initState();
    _loadReadyPlayerMeAvatar();
  }

  Future<void> _loadReadyPlayerMeAvatar() async {
    final avatarPath = await AvatarService.getAvatarImagePath();
    if (avatarPath != null && File(avatarPath).existsSync()) {
      setState(() {
        _readyPlayerMeAvatarPath = avatarPath;
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
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo (Front Camera)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take Photo (Rear Camera)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_fix_high),
                title: const Text('Generate Avatar (AI)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToAvatarGeneration();
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarMainScreen(),
      ),
    );
    
    if (result == true) {
      // Reload the Ready Player Me avatar
      await _loadReadyPlayerMeAvatar();
      setState(() {
        _generatedAvatarBytes = null; // Clear AI generated avatar
        _selectedImageBytes = null; // Clear selected image
      });
      _showSuccessSnackBar('3D Avatar updated successfully!');
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
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white), // Keep white in AppBar
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Header
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _getProfileImage(userService),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle error if needed
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
                Column(
                  children: [
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Message feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[200]
                                  : const Color(0xFF2C2C2C),
                              foregroundColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Change Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
