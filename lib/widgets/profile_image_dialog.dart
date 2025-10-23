import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/liv_theme.dart';

class ProfileImageDialog extends StatelessWidget {
  const ProfileImageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.8,
          maxWidth: screenSize.width * 0.9,
        ),
        decoration: LivDecorations.dialogDecoration,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Choose Profile Image',
                      style: LivTheme.getDialogTitle(context).copyWith(
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black54),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
            
              // Options
              _buildOption(
                context,
                icon: Icons.photo_library_outlined,
                title: 'Choose from Gallery',
                subtitle: 'Select from your photos',
                onTap: () {
                  Navigator.of(context).pop('gallery');
                },
              ),
              
              const SizedBox(height: 12),
              
              _buildOption(
                context,
                icon: Icons.person_outline,
                title: 'Create 3D Avatar',
                subtitle: 'Generate a custom avatar',
                onTap: () {
                  Navigator.of(context).pop('avatar');
                },
              ),
              
              const SizedBox(height: 12),
              
              _buildOption(
                context,
                icon: Icons.visibility_outlined,
                title: 'View Profile',
                subtitle: 'View your current avatar',
                onTap: () {
                  Navigator.of(context).pop('view');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width < 600 ? 40 : 48,
                height: MediaQuery.of(context).size.width < 600 ? 40 : 48,
                decoration: BoxDecoration(
                  color: LivTheme.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: LivTheme.accentBlue,
                  size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width < 600 ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LivTheme.getBlackSubtitle(context).copyWith(
                        fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: LivTheme.getBlackBodySecondary(context).copyWith(
                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: LivTheme.textBlack54,
                size: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ProfileImageDialog(),
    );
  }
}

class FullScreenAvatarViewer extends StatelessWidget {
  final String? imagePath;
  
  const FullScreenAvatarViewer({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: imagePath != null && File(imagePath!).existsSync()
                  ? Image.file(
                      File(imagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackAvatar(context);
                      },
                    )
                  : _buildFallbackAvatar(context),
            ),
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LivTheme.accentBlue.withOpacity(0.2),
        border: Border.all(
          color: LivTheme.accentBlue,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 100,
        color: LivTheme.accentBlue,
      ),
    );
  }

  static Future<void> show(BuildContext context, {String? imagePath}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenAvatarViewer(imagePath: imagePath),
        fullscreenDialog: true,
      ),
    );
  }
}
