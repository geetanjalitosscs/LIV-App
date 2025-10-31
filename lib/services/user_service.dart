import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  
  UserService._internal();
  
  int? _currentUserId;
  
  String? _selectedAvatar;
  String _username = '1234';
  String _displayName = 'User';
  String _bio = 'Looking for new friends!';
  int _age = 25;
  String _location = 'New York';
  
  // Background customization
  String? _backgroundImage;
  int _backgroundColor = 0xFF42A5F5; // Default blue color
  
  // Helper to get user-specific key
  String _getKey(String key) {
    if (_currentUserId == null) return key;
    return 'user_${_currentUserId}_$key';
  }
  
  // Set current user ID (called from AuthService when user logs in/out)
  void setUserId(int? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null) {
        _loadSavedGalleryAvatar();
        _loadSavedBackgroundPreferences();
      } else {
        // Clear data when logged out
        _selectedAvatar = null;
        _backgroundImage = null;
      }
      notifyListeners();
    }
  }
  
  // Getters
  String? get selectedAvatar => _selectedAvatar;
  String get username => _username;
  String get displayName => _displayName;
  String get bio => _bio;
  int get age => _age;
  String get location => _location;
  
  // Background customization getters
  String? get backgroundImage => _backgroundImage;
  int get backgroundColor => _backgroundColor;
  
  // Set default avatar on first access
  String get currentAvatar => _selectedAvatar ?? 'assets/images/pngtree-google.png';
  
  void selectAvatar(String avatarPath) async {
    if (_currentUserId == null) return;
    
    _selectedAvatar = avatarPath;
    
    // Save to SharedPreferences for persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Determine if it's a gallery image or 3D avatar based on path
      if (avatarPath.contains('gallery_')) {
        // Gallery image
        await prefs.setString(_getKey('selectedGalleryAvatar'), avatarPath);
        // Clear 3D avatar data
        await prefs.remove(_getKey('lastAvatarId'));
        await prefs.remove(_getKey('lastAvatarPngPath'));
        await prefs.remove(_getKey('lastAvatarGlbPath'));
      } else {
        // 3D avatar
        await prefs.setString(_getKey('lastAvatarPngPath'), avatarPath);
        // Extract avatar ID from path
        final fileName = avatarPath.split(Platform.isWindows ? '\\' : '/').last;
        final avatarId = fileName.replaceAll('.png', '');
        await prefs.setString(_getKey('lastAvatarId'), avatarId);
        
        // Check for GLB file
        final glbPath = avatarPath.replaceAll('.png', '.glb');
        if (File(glbPath).existsSync()) {
          await prefs.setString(_getKey('lastAvatarGlbPath'), glbPath);
        }
        
        // Clear gallery image data
        await prefs.remove(_getKey('selectedGalleryAvatar'));
      }
      
      print('Profile avatar saved for user $_currentUserId: $avatarPath');
    } catch (e) {
      print('Error saving profile avatar: $e');
    }
    
    notifyListeners();
  }
  
  // Load saved profile avatar from SharedPreferences
  Future<void> _loadSavedGalleryAvatar() async {
    if (_currentUserId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First check for gallery image
      String? savedAvatarPath = prefs.getString(_getKey('selectedGalleryAvatar'));
      
      // If no gallery image, check for 3D avatar
      if (savedAvatarPath == null || !File(savedAvatarPath).existsSync()) {
        savedAvatarPath = prefs.getString(_getKey('lastAvatarPngPath'));
      }
      
      if (savedAvatarPath != null && File(savedAvatarPath).existsSync()) {
        _selectedAvatar = savedAvatarPath;
        print('Loaded saved profile avatar for user $_currentUserId: $savedAvatarPath');
        notifyListeners();
      } else {
        print('No valid saved profile avatar found for user $_currentUserId');
      }
    } catch (e) {
      print('Error loading saved profile avatar: $e');
    }
  }

  // Load saved background preferences from SharedPreferences
  Future<void> _loadSavedBackgroundPreferences() async {
    if (_currentUserId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBackgroundImage = prefs.getString(_getKey('profileBackgroundImage'));
      final savedBackgroundColor = prefs.getInt(_getKey('profileBackgroundColor'));
      
      if (savedBackgroundImage != null && File(savedBackgroundImage).existsSync()) {
        _backgroundImage = savedBackgroundImage;
      }
      if (savedBackgroundColor != null) {
        _backgroundColor = savedBackgroundColor;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading saved background preferences: $e');
    }
  }
  
  void updateProfile({
    String? displayName,
    String? bio,
    int? age,
    String? location,
    String? backgroundImage,
    int? backgroundColor,
  }) async {
    if (_currentUserId == null) return;
    
    if (displayName != null) _displayName = displayName;
    if (bio != null) _bio = bio;
    if (age != null) _age = age;
    if (location != null) _location = location;
    if (backgroundImage != null) _backgroundImage = backgroundImage;
    if (backgroundColor != null) _backgroundColor = backgroundColor;
    
    // Save background preferences to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (backgroundImage != null) {
        await prefs.setString(_getKey('profileBackgroundImage'), backgroundImage);
      }
      if (backgroundColor != null) {
        await prefs.setInt(_getKey('profileBackgroundColor'), backgroundColor);
      }
    } catch (e) {
      print('Error saving background preferences: $e');
    }
    
    notifyListeners();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': _username,
      'displayName': _displayName,
      'bio': _bio,
      'age': _age,
      'location': _location,
      'selectedAvatar': _selectedAvatar,
    };
  }
  
  void fromJson(Map<String, dynamic> json) {
    _username = json['username'] ?? '1234';
    _displayName = json['displayName'] ?? 'User';
    _bio = json['bio'] ?? 'Looking for my soulmate!';
    _age = json['age'] ?? 25;
    _location = json['location'] ?? 'New York';
    _selectedAvatar = json['selectedAvatar'];
    notifyListeners();
  }
}
