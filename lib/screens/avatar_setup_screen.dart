import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import 'avatar_generation_screen.dart';

class AvatarSetupScreen extends StatefulWidget {
  const AvatarSetupScreen({super.key});

  @override
  State<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends State<AvatarSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late Animation<Color?> _backgroundTint;
  late Animation<double> _pulseScale;

  double _energyLevel = 5.0;
  double _fitnessLevel = 5.0;
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
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _backgroundTint = ColorTween(
      begin: const Color(0xFF667eea),
      end: const Color(0xFF764ba2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Setup Your Profile',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
              const SizedBox(height: 32),
              
              // Avatar Generation Section
              const Text(
                'Generate Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Current Avatar Display
              Center(
                child: Consumer<UserService>(
                  builder: (context, userService, child) {
                    return GestureDetector(
                      onTap: () => _navigateToAvatarGeneration(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            userService.currentAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.person,
                                  color: Theme.of(context).primaryColor,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to generate your avatar',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Profile Information Section
              Text(
                'Profile Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bio Field
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info),
                ),
              ),
              const SizedBox(height: 16),
              
              // Age and Location Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Energy Level Slider
              Text(
                'Energy Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _energyLevel,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _energyLevel = value;
                  });
                },
              ),
              Text(
                '${_energyLevel.round()}/10',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 24),
              
              // Fitness Level Slider
              Text(
                'Fitness Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _fitnessLevel,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _fitnessLevel = value;
                  });
                },
              ),
              Text(
                '${_fitnessLevel.round()}/10',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
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
        Navigator.pop(context);
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

  // Navigate to avatar generation screen
  Future<void> _navigateToAvatarGeneration() async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarGenerationScreen(),
      ),
    );
    
    if (result != null) {
      // Update the user service with the generated avatar
      final userService = UserService.instance;
      userService.selectAvatar('generated_avatar'); // Mark as generated
      // You might want to store the actual image bytes in a different way
      // For now, we'll just refresh the UI
      setState(() {});
      _showSuccessSnackBar('Avatar generated successfully!');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}