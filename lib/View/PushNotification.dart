import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level background handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Add logic to handle background notifications here
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
      );
      print("Notification permissions requested.");

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
      } else {
        print("Failed to get FCM token.");
      }

      await _firebaseMessaging.subscribeToTopic('all_devices');
      print("Subscribed to 'all_devices' topic");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received message while in foreground: ${message.messageId}');
        if (message.notification != null) {
          print('Notification title: ${message.notification?.title}');
          print('Notification body: ${message.notification?.body}');
        }
        _showInAppNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification opened while in background: ${message.messageId}');
      });

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print('App launched from terminated state: ${message.messageId}');
        }
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      print("Error initializing notification service: $e");
    }
  }

  void _showInAppNotification(RemoteMessage message) {
    print('Showing in-app notification: ${message.notification?.title}');
  }
}