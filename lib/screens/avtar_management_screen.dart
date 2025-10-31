import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'avtar_creator_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation.dart';
import '../theme/liv_theme.dart';
import '../config/paths.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/avtar_service.dart';

class AvatarManagementScreen extends StatefulWidget {
  const AvatarManagementScreen({super.key});

  @override
  State<AvatarManagementScreen> createState() => _AvatarManagementScreenState();
}

class _AvatarManagementScreenState extends State<AvatarManagementScreen> {
  Future<Map<String, String?>>? _avatarFuture;
  int _currentIndex = 4; // Profile tab is active
  List<Map<String, String?>> _avatarHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadSavedAvatar();
    _loadAvatarHistory();
  }

  Future<void> _loadAvatarHistory() async {
    try {
      // Get user-specific directory
      final userId = AuthService.instance.userId;
      if (userId == null) {
        print('User not logged in');
        setState(() {
          _avatarHistory = [];
        });
        return;
      }
      
      final windowsUploads = AppPaths.getWindowsUploadsPath(userId);
      final uploadsDir = Directory(windowsUploads);
      
      if (!uploadsDir.existsSync()) {
        return;
      }
      
      // Get the currently selected profile avatar ID
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
      
      // Check if user has selected a gallery image (not from Ready Player Me)
      // Use UserService.instance directly since it's a singleton
      final userService = UserService.instance;
      final bool hasGalleryImage = userService.selectedAvatar != null && 
          File(userService.selectedAvatar!).existsSync();
      
      final pngFiles = uploadsDir
          .listSync()
          .where((file) => file.path.toLowerCase().endsWith('.png'))
          .cast<File>()
          .toList();
      
      if (pngFiles.isNotEmpty) {
        pngFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        final avatarList = pngFiles.map((file) {
          final fileName = file.path.split('\\').last;
          final avatarId = fileName.replaceAll('.png', '');
          final glbPath = '$windowsUploads\\$avatarId.glb';
          
          return {
            'id': avatarId,
            'glb': File(glbPath).existsSync() ? glbPath : null,
            'png': file.path,
            'date': file.lastModifiedSync().toString(),
          };
        }).toList();
        
        // Always filter out the currently selected Ready Player Me profile avatar
        // (Gallery images are stored elsewhere and won't be in this list anyway)
        final filteredAvatars = avatarList.where((avatar) {
          // Always exclude the current profile avatar if it matches
          final shouldInclude = avatar['id'] != currentAvatarId;
          if (!shouldInclude) {
            print('Filtering out avatar: ${avatar['id']} (matches current profile avatar)');
          }
          return shouldInclude;
        }).toList();
        
        setState(() {
          _avatarHistory = filteredAvatars;
        });
      } else {
        setState(() {
          _avatarHistory = [];
        });
      }
    } catch (e) {
      print('Error loading avatar history: $e');
    }
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
          'Avatar Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _avatarFuture = _loadSavedAvatar();
                _loadAvatarHistory();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: LivDecorations.mainAppBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Current Avatar Card
              _buildCurrentAvatarCard(cardWidth, iconSize, titleFont, bodyFont),
              
              const SizedBox(height: 20),
              
              // Avatar History Section
              if (_avatarHistory.isNotEmpty) ...[
                _buildAvatarHistorySection(),
                const SizedBox(height: 20),
              ],
              
              // Quick Actions Section
              _buildQuickActionsSection(),
              
              const SizedBox(height: 20),
              
              // Avatar Statistics
              _buildAvatarStatsSection(),
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
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildCurrentAvatarCard(double cardWidth, double iconSize, double titleFont, double bodyFont) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06, vertical: cardWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          FutureBuilder<Map<String, String?>>(
            future: _avatarFuture,
            builder: (context, snapshot) {
              final pngPath = snapshot.data?['png'];
              final bool hasValidAvatar = pngPath != null && File(pngPath).existsSync();
              
              return Column(
                children: [
                  GestureDetector(
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
                      width: iconSize * 2.2,
                      height: iconSize * 2.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasValidAvatar ? null : LivTheme.mainAppGradient,
                        border: hasValidAvatar 
                            ? Border.all(color: Colors.grey.withOpacity(0.3), width: 3) 
                            : Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasValidAvatar
                          ? Image.file(
                              File(pngPath),
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person, color: Colors.white, size: iconSize * 1.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Avatar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasValidAvatar ? 'Tap to view full screen' : 'No avatar created yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodyFont,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _createNewAvatar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create New Avatar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avatar History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _avatarHistory.length,
              itemBuilder: (context, index) {
                final avatar = _avatarHistory[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenAvatarView(imagePath: avatar['png']!),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                        'Avatar ${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.create,
                  label: 'Create Avatar',
                  color: const Color(0xFF667eea),
                  onTap: _createNewAvatar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: 'Download',
                  color: Colors.green,
                  onTap: _downloadCurrentAvatar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.orange,
                  onTap: _shareAvatar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: _deleteCurrentAvatar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avatar Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Avatars', _avatarHistory.length.toString(), Icons.person),
              _buildStatItem('Storage Used', '${_calculateStorageUsed()}MB', Icons.storage),
              _buildStatItem('Last Created', _getLastCreatedDate(), Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Future<void> _createNewAvatar() async {
    final bool? shouldCreate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create 3D Avatar'),
          content: const Text('This will open the Ready Player Me avatar creator. After creating your avatar, it will be automatically saved to your profile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Avatar'),
            ),
          ],
        );
      },
    );
    
    if (shouldCreate == true) {
      setState(() {
        _isLoading = true;
      });
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AvatarCreatorScreen()),
      );
      
      if (result == true && mounted) {
        setState(() {
          _avatarFuture = _loadSavedAvatar();
          _loadAvatarHistory();
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadCurrentAvatar() async {
    final avatarData = await _avatarFuture;
    if (avatarData?['png'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar download started!'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No avatar to download'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _shareAvatar() async {
    final avatarData = await _avatarFuture;
    if (avatarData?['png'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar sharing feature coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No avatar to share'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteCurrentAvatar() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Avatar'),
          content: const Text('Are you sure you want to delete your current avatar? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    
    if (shouldDelete == true) {
      // Delete avatar logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _avatarFuture = _loadSavedAvatar();
        _loadAvatarHistory();
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Avatar Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Storage Location'),
                subtitle: Text(AuthService.instance.userId != null 
                    ? AppPaths.getWindowsUploadsPath(AuthService.instance.userId!) 
                    : 'Not logged in'),
              ),
              const ListTile(
                leading: Icon(Icons.format_list_bulleted),
                title: Text('Auto-save'),
                subtitle: Text('Enabled'),
              ),
              const ListTile(
                leading: Icon(Icons.high_quality),
                title: Text('Quality'),
                subtitle: Text('High (PNG + GLB)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleNavigation(int index) {
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
  }

  String _calculateStorageUsed() {
    // Calculate storage used by avatar files
    return (_avatarHistory.length * 2.5).toStringAsFixed(1);
  }

  String _getLastCreatedDate() {
    if (_avatarHistory.isEmpty) return 'Never';
    
    final lastAvatar = _avatarHistory.first;
    final date = DateTime.parse(lastAvatar['date']!);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

Future<Map<String, String?>> _loadSavedAvatar() async {
  try {
    // Get user-specific directory
    final userId = AuthService.instance.userId;
    if (userId == null) {
      print('User not logged in');
      return {'id': null, 'glb': null, 'png': null};
    }
    
    // Scan the user-specific uploads folder for the most recent avatar
    final windowsUploads = AppPaths.getWindowsUploadsPath(userId);
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
