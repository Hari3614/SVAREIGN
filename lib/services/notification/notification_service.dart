import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/notification/notification_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permission for notifications
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Subscribe to a general topic for service providers
    await FirebaseMessaging.instance.subscribeToTopic('service_requests');
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');

    // Show in-app notification
    _showInAppNotification(
      title: message.notification?.title ?? 'New Request',
      body:
          message.notification?.body ??
          'You have received a new service request',
    );
  }

  // Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('Background message received: ${message.notification?.title}');

    // Handle background message (e.g., update local database)
    // Note: This runs in an isolate, so UI operations are not possible here
  }

  // Handle when app is opened from terminated state
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print(
      'App opened from terminated state with message: ${message.notification?.title}',
    );

    // Navigate to appropriate screen if needed
  }

  // Show in-app notification using the NotificationProvider
  void _showInAppNotification({required String title, required String body}) {
    // This method will be called by the main app where we have access to context
    print('In-app notification: $title - $body');

    // We'll use a callback mechanism to show notifications in the UI
    _onNotificationReceived?.call(title, body);
  }

  // Callback for when notifications are received
  Function(String title, String body)? _onNotificationReceived;

  // Set callback for notification received
  void setOnNotificationReceived(Function(String title, String body) callback) {
    _onNotificationReceived = callback;
  }

  // Send notification to a specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      // In a real implementation, you would send this to your backend
      // which would then use FCM to send the notification to the specific user
      print('Sending notification to user $userId: $title - $body');

      // For demo purposes, we'll simulate receiving a notification
      _simulateNotification(title: title, body: body);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Simulate receiving a notification (for demo/testing)
  void _simulateNotification({required String title, required String body}) {
    // This would typically be called when we detect a new request in Firestore
    _showInAppNotification(title: title, body: body);
  }

  // Listen for new requests in Firestore for a specific user (both customers and providers)
  void listenForNewRequests(Function(String title, String body) onNewRequest) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Set the callback for notifications
    setOnNotificationReceived(onNewRequest);

    // Listen for new requests in the user's collection (for customers)
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final providerName = data['providerName'] ?? 'A service provider';

              onNewRequest(
                'New Service Request',
                '$providerName has sent you a service request',
              );
            }
          }
        });

    // Listen for new requests in the service provider's collection (for providers)
    FirebaseFirestore.instance
        .collection('services')
        .doc(userId)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final userName = data['userName'] ?? 'A user';

              onNewRequest(
                'New Service Request',
                '$userName has requested your service',
              );
            }
          }
        });

    // Listen for new bookings in the service provider's collection (for providers)
    FirebaseFirestore.instance
        .collection('services')
        .doc(userId)
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final userName = data['userName'] ?? 'A user';

              onNewRequest(
                'New Booking Request',
                '$userName has booked your service',
              );
            }
          }
        });
  }
}
