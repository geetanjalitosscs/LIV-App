import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  static MessagingService get instance => _instance;
  
  MessagingService._internal();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  Future<void> initialize() async {
    // Notifications disabled (Firebase removed)
    _fcmToken = null;
  }
  
  Future<void> subscribeToTopic(String topic) async {}
  Future<void> unsubscribeFromTopic(String topic) async {}
  Future<void> sendNotificationToUser(String userId, {required String title, required String body, Map<String, dynamic>? data}) async {
    print('Notification (stub) to $userId: $title - $body');
  }
}
