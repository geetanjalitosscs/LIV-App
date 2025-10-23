import 'package:flutter/foundation.dart';
import 'dart:async';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  
  UserService._internal();
  
  String? _selectedAvatar;
  String _username = '1234';
  String _displayName = 'User';
  String _bio = 'Looking for new friends!';
  int _age = 25;
  String _location = 'New York';
  
  // Background customization
  String? _backgroundImage;
  int _backgroundColor = 0xFF42A5F5; // Default blue color
  
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
  
  void selectAvatar(String avatarPath) {
    _selectedAvatar = avatarPath;
    notifyListeners();
  }
  
  void updateProfile({
    String? displayName,
    String? bio,
    int? age,
    String? location,
    String? backgroundImage,
    int? backgroundColor,
  }) {
    if (displayName != null) _displayName = displayName;
    if (bio != null) _bio = bio;
    if (age != null) _age = age;
    if (location != null) _location = location;
    if (backgroundImage != null) _backgroundImage = backgroundImage;
    if (backgroundColor != null) _backgroundColor = backgroundColor;
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
