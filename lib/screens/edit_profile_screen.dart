import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../theme/liv_theme.dart';
import '../services/theme_service.dart';
import '../config/paths.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedGender;
  
  // Store original values to detect changes
  String? _originalFullName;
  String? _originalPhone;
  String? _originalGender;
  int? _originalAge;
  String? _originalLocation;
  String? _originalBio;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      final authService = AuthService.instance;
      final userData = authService.userData;
      
      if (userData != null) {
        // Load data from database
        _originalFullName = userData['full_name']?.toString() ?? '';
        _originalPhone = userData['phone']?.toString() ?? '';
        _originalAge = userData['age'] != null ? int.tryParse(userData['age'].toString()) : null;
        _originalGender = userData['gender']?.toString();
        _originalLocation = userData['location']?.toString() ?? '';
        _originalBio = userData['bio']?.toString() ?? '';
        
        _fullNameController.text = _originalFullName ?? '';
        _phoneController.text = _originalPhone ?? '';
        _ageController.text = _originalAge?.toString() ?? '';
        _selectedGender = _originalGender;
        _locationController.text = _originalLocation ?? '';
        _bioController.text = _originalBio ?? '';
      } else {
        // No database data - leave fields empty (no dummy data)
        _originalFullName = '';
        _originalBio = '';
        _originalAge = null;
        _originalLocation = '';
        _originalPhone = '';
        _originalGender = null;
        
        _fullNameController.text = '';
        _bioController.text = '';
        _ageController.text = '';
        _locationController.text = '';
        _selectedGender = null;
      }
    } catch (e) {
      print('Error loading user data: $e');
      // No database data - leave fields empty (no dummy data)
      _originalFullName = '';
      _originalBio = '';
      _originalAge = null;
      _originalLocation = '';
      _originalPhone = '';
      _originalGender = null;
      
      _fullNameController.text = '';
      _bioController.text = '';
      _ageController.text = '';
      _locationController.text = '';
      _selectedGender = null;
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
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
                  child: _isLoadingData
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Name Field (from database)
                            TextFormField(
                              controller: _fullNameController,
                              decoration: LivInputStyles.getGlassmorphicInputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            
                            // Phone Field (from database)
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: LivInputStyles.getGlassmorphicInputDecoration(
                                labelText: 'Phone',
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            
                            // Gender Dropdown (from database)
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: LivInputStyles.getGlassmorphicInputDecoration(
                                labelText: 'Gender',
                                prefixIcon: const Icon(Icons.people),
                              ),
                              dropdownColor: const Color(0xFF2D2D2D),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              items: ['Male', 'Female', 'Other']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Age Field (from database)
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
                            
                            // Bio Field (local preference)
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
                            
                            // Location Field (from database)
                            TextFormField(
                              controller: _locationController,
                              decoration: LivInputStyles.getGlassmorphicInputDecoration(
                                labelText: 'Location',
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button with Highlight Background
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      print('Save button clicked!');
                      _saveProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                    ),
                    child: Container(
                      decoration: LivDecorations.editProfileButton,
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
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

  /// Show success popup and wait for it to be dismissed
  Future<void> _showSuccessAndWait(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: LivTheme.accentGreen.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: LivTheme.accentGreen.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      LivTheme.accentGreen,
                      LivTheme.accentGreen.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LivTheme.accentGreen.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              // Message Text
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: LivTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LivTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
      final authService = AuthService.instance;
      final userId = authService.userId;
      
      if (userId == null) {
        throw Exception('User must be logged in to update profile');
      }
      
      // Validate age
      final age = int.tryParse(_ageController.text.trim());
      if (age == null || age < 1 || age > 150) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          LivPopupMessage.showError(context, 'Please enter a valid age');
        }
        return;
      }
      
      // Check if any data has changed
      final currentFullName = _fullNameController.text.trim();
      final currentPhone = _phoneController.text.trim();
      final currentGender = _selectedGender ?? '';
      final currentLocation = _locationController.text.trim();
      final currentBio = _bioController.text.trim();
      
      // Normalize values for comparison (handle null/empty)
      final origFullName = (_originalFullName ?? '').trim();
      final origPhone = (_originalPhone ?? '').trim();
      final origGender = (_originalGender ?? '').trim();
      final origLocation = (_originalLocation ?? '').trim();
      final origBio = (_originalBio ?? '').trim();
      final origAge = _originalAge ?? 0;
      
      final fullNameChanged = currentFullName != origFullName;
      final phoneChanged = currentPhone != origPhone;
      final genderChanged = currentGender != origGender;
      final ageChanged = age != origAge;
      final locationChanged = currentLocation != origLocation;
      final bioChanged = currentBio != origBio;
      
      final bool hasChanges = fullNameChanged || phoneChanged || genderChanged || ageChanged || locationChanged || bioChanged;
      
      print('Change detection:');
      print('  FullName: "$currentFullName" vs "$origFullName" = $fullNameChanged');
      print('  Phone: "$currentPhone" vs "$origPhone" = $phoneChanged');
      print('  Gender: "$currentGender" vs "$origGender" = $genderChanged');
      print('  Age: $age vs $origAge = $ageChanged');
      print('  Location: "$currentLocation" vs "$origLocation" = $locationChanged');
      print('  Bio: "$currentBio" vs "$origBio" = $bioChanged');
      print('Has changes: $hasChanges');
      
      if (!hasChanges) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          LivPopupMessage.showInfo(context, 'Please update details before saving.');
        }
        return;
      }
      
          // Update database via API
          print('Saving profile with userId: $userId');
          final response = await http.post(
            Uri.parse('${AppPaths.apiBaseUrl}/update_profile.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'full_name': currentFullName,
              'phone': currentPhone,
              'gender': currentGender,
              'age': age,
              'location': currentLocation,
              'bio': currentBio,
            }),
          );
      
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Profile update successful, refreshing user data...');
          
              // Bio is now saved to database, no need for local UserService update
          
              // Update original values from the response data (faster than API call)
              _originalFullName = data['user']['full_name']?.toString() ?? currentFullName;
              _originalPhone = data['user']['phone']?.toString() ?? currentPhone;
              _originalAge = data['user']['age'] != null ? int.tryParse(data['user']['age'].toString()) : age;
              _originalGender = data['user']['gender']?.toString() ?? currentGender;
              _originalLocation = data['user']['location']?.toString() ?? currentLocation;
              _originalBio = data['user']['bio']?.toString() ?? currentBio;
          
          print('Original values updated after save:');
          print('  FullName: $_originalFullName, Phone: $_originalPhone, Gender: $_originalGender');
          print('  Age: $_originalAge, Location: $_originalLocation, Bio: $_originalBio');
          
          // Update AuthService with new user data (refresh in background)
          try {
            await authService.refreshUserData();
            print('User data refreshed in AuthService');
          } catch (e) {
            print('Error refreshing AuthService (non-critical): $e');
            // Non-critical error, continue anyway
          }
          
          if (mounted) {
            // Stop loading first
            setState(() {
              _isLoading = false;
            });
            
            // Show success popup and wait for it to be dismissed
            print('Showing success popup...');
            await _showSuccessAndWait(context, 'Profile saved successfully!');
            
            // After popup is dismissed, close the edit screen
            if (mounted && Navigator.of(context).canPop()) {
              print('Closing edit profile screen...');
              Navigator.of(context).pop(true); // Return true to indicate update
            }
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to update profile');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _saveProfile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        LivPopupMessage.showError(context, 'Error saving profile: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }
  }
}
