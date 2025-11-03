import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/paths.dart';
import 'auth_service.dart';

class ActivityService extends ChangeNotifier {
  static final ActivityService _instance = ActivityService._internal();
  static ActivityService get instance => _instance;
  
  ActivityService._internal() {
    // Start listening to auth state changes
    AuthService.instance.onAuthStateChanged.listen((bool isSignedIn) {
      if (isSignedIn) {
        _startHeartbeat();
      } else {
        _stopHeartbeat();
      }
    });
    
    // Start heartbeat if already signed in
    if (AuthService.instance.isSignedIn) {
      _startHeartbeat();
    }
  }
  
  Timer? _heartbeatTimer;
  Map<int, bool> _onlineUsers = {}; // Map of user_id -> is_online
  
  // Check online status every 30 seconds
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  // Check online users every 60 seconds
  static const Duration _onlineCheckInterval = Duration(seconds: 60);
  
  Timer? _onlineCheckTimer;
  
  Map<int, bool> get onlineUsers => Map.unmodifiable(_onlineUsers);
  
  bool isUserOnline(int userId) {
    return _onlineUsers[userId] ?? false;
  }
  
  void _startHeartbeat() {
    _stopHeartbeat(); // Stop any existing timer
    
    // Send immediate heartbeat
    _updateActivity();
    
    // Then send periodic heartbeats
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _updateActivity();
    });
    
    // Also start checking online users
    _checkOnlineUsers();
    _onlineCheckTimer = Timer.periodic(_onlineCheckInterval, (_) {
      _checkOnlineUsers();
    });
  }
  
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _onlineCheckTimer?.cancel();
    _onlineCheckTimer = null;
  }
  
  Future<void> _updateActivity() async {
    final userId = AuthService.instance.userId;
    if (userId == null) return;
    
    try {
      await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/update_activity.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating activity: $e');
      }
    }
  }
  
  Future<void> _checkOnlineUsers() async {
    try {
      final response = await http.post(
        Uri.parse('${AppPaths.apiBaseUrl}/get_online_users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final Map<String, dynamic> onlineUsersMap = data['online_users'];
          final Map<int, bool> newOnlineUsers = {};
          
          onlineUsersMap.forEach((key, value) {
            final userId = int.tryParse(key);
            if (userId != null) {
              newOnlineUsers[userId] = value == true || value == 1;
            }
          });
          
          _onlineUsers = newOnlineUsers;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking online users: $e');
      }
    }
  }
  
  // Manually refresh online status (can be called from UI)
  Future<void> refreshOnlineStatus() async {
    await _checkOnlineUsers();
  }
  
  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
}

