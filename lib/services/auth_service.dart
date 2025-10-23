import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  
  AuthService._internal();
  
  bool _isSignedIn = false;
  bool _isLoading = false;
  String? _currentUser;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  
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
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = email;
    _isSignedIn = true;
    _isLoading = false;
    _authStateController.add(true);
    notifyListeners();
    return true;
  }
  
  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    return signInWithEmailAndPassword(email, password);
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