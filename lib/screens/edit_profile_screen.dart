import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../theme/liv_theme.dart';
import '../services/theme_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current user data
    final userService = UserService.instance;
    _nameController.text = userService.displayName;
    _bioController.text = userService.bio;
    _ageController.text = userService.age.toString();
    _locationController.text = userService.location;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Profile Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: LivDecorations.mainAppBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Profile Information Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: LivDecorations.glassmorphicCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: LivInputStyles.getGlassmorphicInputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      
                      // Bio Field
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: LivInputStyles.getGlassmorphicInputDecoration(
                          labelText: 'Bio',
                          prefixIcon: const Icon(Icons.info),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      
                      // Age Field
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: LivInputStyles.getGlassmorphicInputDecoration(
                          labelText: 'Age',
                          prefixIcon: const Icon(Icons.cake),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      
                      // Location Field
                      TextFormField(
                        controller: _locationController,
                        decoration: LivInputStyles.getGlassmorphicInputDecoration(
                          labelText: 'Location',
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button with Highlight Background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: LivDecorations.editProfileButton,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: LivButtonStyles.glassmorphicSaveButton,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update user profile with edited information
      final userService = UserService.instance;
      final age = int.tryParse(_ageController.text) ?? userService.age;
      
      userService.updateProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        age: age,
        location: _locationController.text.trim(),
      );
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
