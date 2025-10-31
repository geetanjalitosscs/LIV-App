import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/paths.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  
  AuthService._internal();
  
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _currentUser;
  Map<String, dynamic>? _userData;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  
  Stream<bool> get onAuthStateChanged => _authStateController.stream;
  
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _isSignedIn = true;
    _currentUser = 'guest@example.com';
    _isLoading = false;
    _authStateController.add(true);
    notifyListeners();
    return true;
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
          _currentUser = email;
          _userData = data['user'];
          _isSignedIn = true;
          _isLoading = false;
          _authStateController.add(true);
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
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = email;
          _isSignedIn = true;
          _isLoading = false;
          _authStateController.add(true);
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
  
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
  
  Future<void> signOut() async {
    _isSignedIn = false;
    _currentUser = null;
    _authStateController.add(false);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}