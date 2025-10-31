import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/paths.dart';
import '../theme/liv_theme.dart';
import 'user_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  
  AuthService._internal() {
    _loadSavedUser();
  }
  
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _currentUser;
  int? _userId;
  Map<String, dynamic>? _userData;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  int? get userId => _userId;
  Map<String, dynamic>? get userData => _userData;
  
  Stream<bool> get onAuthStateChanged => _authStateController.stream;
  
  // Helper function to safely parse user ID from JSON (handles both String and int)
  int _parseUserId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.parse(id);
    throw Exception('Invalid user ID format: $id');
  }
  
  // Load saved user session
  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getInt('userId');
      final savedEmail = prefs.getString('userEmail');
      
      if (savedUserId != null && savedEmail != null) {
        _userId = savedUserId;
        _currentUser = savedEmail;
        _isSignedIn = true;
        _authStateController.add(true);
        // Update UserService with saved user ID
        UserService.instance.setUserId(savedUserId);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved user: $e');
    }
  }
  
  // Save user session
  Future<void> _saveUserSession(int userId, String email, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('userEmail', email);
      _userId = userId;
      _currentUser = email;
      _userData = userData;
      _isSignedIn = true;
      _authStateController.add(true);
      // Update UserService with new user ID
      UserService.instance.setUserId(userId);
      notifyListeners();
    } catch (e) {
      print('Error saving user session: $e');
    }
  }
  
  // Clear user session
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      _userId = null;
      _currentUser = null;
      _userData = null;
      _isSignedIn = false;
      _authStateController.add(false);
      // Clear UserService user ID
      UserService.instance.setUserId(null);
      notifyListeners();
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }
  
  Future<bool> signInWithGoogle({required BuildContext context}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Show dialog to get user ID
      final userIdText = await _showUserIdDialog(context);
      if (userIdText == null || userIdText.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final userId = int.tryParse(userIdText.trim());
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        throw Exception('Invalid user ID. Please enter a number.');
      }
      
      // Call API to get user by ID
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_user_by_id.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          final email = userData['email'] as String;
          await _saveUserSession(userId, email, userData);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          notifyListeners();
          throw Exception(data['error'] ?? 'User not found');
        }
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }
  
  // Show dialog to get user ID
  Future<String?> _showUserIdDialog(BuildContext context) async {
    final TextEditingController userIdController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
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
                color: LivTheme.accentBlue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: LivTheme.accentBlue.withOpacity(0.3),
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
                        LivTheme.accentBlue,
                        LivTheme.accentBlue.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LivTheme.accentBlue.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Continue with Google',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: LivTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Enter your user ID from the database',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: LivTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Text Field
                TextField(
                  controller: userIdController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: LivInputStyles.getGlassmorphicInputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter your user ID',
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: LivTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(userIdController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LivTheme.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
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
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<bool> signInWithEmail(String email, String password) async {
    return signInWithEmailAndPassword(email, password);
  }
  
  Future<bool> signUpWithEmail(String email, String password) async {
    return createUserWithEmailAndPassword(email, password);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          // Safely parse user ID - handle both String and int from JSON
          final userId = _parseUserId(userData['id']);
          await _saveUserSession(userId, email, userData);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          notifyListeners();
          throw Exception(data['error'] ?? 'Login failed');
        }
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<bool> createUserWithEmailAndPassword(
    String email, 
    String password, {
    String? fullName,
    String? phone,
    String? gender,
    int? age,
    String? location,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': fullName ?? '',
          'email': email,
          'phone': phone ?? '',
          'password': password,
          'gender': gender ?? '',
          'age': age ?? 0,
          'location': location ?? '',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          // Safely parse user ID - handle both String and int from JSON
          final userId = _parseUserId(userData['id']);
          await _saveUserSession(userId, email, userData);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          notifyListeners();
          throw Exception(data['error'] ?? 'Signup failed');
        }
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Signup failed: ${e.toString()}');
    }
  }
  
  // Refresh user data from database
  Future<void> refreshUserData() async {
    final userId = _userId;
    if (userId == null) return;
    
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_user_by_id.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _userData = data['user'];
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
  
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
  
  Future<void> signOut() async {
    await _clearUserSession();
  }
  
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}