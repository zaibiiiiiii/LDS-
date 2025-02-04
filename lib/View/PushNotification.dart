// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// final FlutterLocalNotificationsPlugin notificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// // Top-level background handler
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
//   // Add logic to handle background notifications here
// }
//
// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> initialize() async {
//     try {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         announcement: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//       );
//       print("Notification permissions requested.");
//
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         print("FCM Token: $token");
//       } else {
//         print("Failed to get FCM token.");
//       }
//
//       await _firebaseMessaging.subscribeToTopic('all_devices');
//       print("Subscribed to 'all_devices' topic");
//
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print('Received message while in foreground: ${message.messageId}');
//         if (message.notification != null) {
//           print('Notification title: ${message.notification?.title}');
//           print('Notification body: ${message.notification?.body}');
//         }
//         _showInAppNotification(message);
//       });
//
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         print('Notification opened while in background: ${message.messageId}');
//       });
//
//       FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//         if (message != null) {
//           print('App launched from terminated state: ${message.messageId}');
//         }
//       });
//
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//     } catch (e) {
//       print("Error initializing notification service: $e");
//     }
//   }
//
//   void _showInAppNotification(RemoteMessage message) {
//     print('Showing in-app notification: ${message.notification?.title}');
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../l10n/app_localizations.dart';


class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Timer _timer;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Set<String> _shownNotificationIds = {}; // To avoid duplicate notifications
  final List<Map<String, String>> _notifications = []; // For UI display
  bool _notificationsFetched = false; // Track whether notifications are fetched already
  static const String channelId = 'general_notifications';
  static const String channelName = 'General Notifications';
  StreamSubscription? _notificationStreamSubscription;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _startNotificationListener(); // Start listening for new notifications
    _loadShownNotifications(); // Load previously shown IDs from storage

    _configureFCM(); // Configure Firebase Cloud Messaging
    if (!_notificationsFetched) {
      _fetchNotifications(); // Fetch notifications only once
      _startNotificationTimer(); // Start periodic notification fetch
    }
  }
  void _startNotificationTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      await _fetchNotifications();
    });
  }
  Future<void> _loadShownNotifications() async {
    final String? storedIds = await _storage.read(key: 'shown_notification_ids');
    if (storedIds != null) {
      _shownNotificationIds.addAll(
          List<int>.from(jsonDecode(storedIds)) as Iterable<String>); // Decode and add to set
      // Decode and add to set
    }
  }
  Future<void> _saveShownNotifications() async {
    await _storage.write(
        key: 'shown_notification_ids',
        value: jsonEncode(_shownNotificationIds.toList())); // Encode and store
  }
  void _startNotificationListener() {
    // 1. Create a periodic timer to check for new notifications
    const checkInterval = Duration(seconds: 5); // Adjust as needed
    _notificationStreamSubscription =
        Stream.periodic(checkInterval).listen((_) {
          _fetchAndShowNewNotifications();
        });
  }
  Future<void> _fetchAndShowNewNotifications() async {
    try {
      final String? token = await _storage.read(key: 'AccessToken');
      final String? companyid = await _storage.read(key: 'Company_Id');
      if (token == null) {
        print('Token not found');
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse(
            'https://posapi.lakhanisolution.com/api/App/GetCompanyNotification?Company_Id=$companyid'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> notifications = data['result'][0];

        for (var notification in notifications) {
          int id = notification['Notification_Id'];

          if (_shownNotificationIds.contains(id.toString())) continue; // Check using String

          _shownNotificationIds.add(id.toString()); // Add as String

          _saveShownNotifications(); // Save the updated set

          String title = notification['Notification_Type'] ?? 'No Title';
          String body = notification['Notification_Msg'] ?? 'No Message';

          // Show local notification
          _showLocalNotification(RemoteNotification(
            title: title,
            body: body,
          ), id); // Pass the ID to _showLocalNotification
        }
      } else {
        print(
            'Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NotificationScreen()
            ),
          );
        }
      },
    );

    const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

           flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  // Configure Firebase Cloud Messaging (FCM)
  Future<void> _configureFCM() async {
    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Print when a notification is received in the foreground
        print('Received a foreground notification: ${message.notification!.title}, ${message.notification!.body}');
        _showLocalNotification(message.notification!,message.hashCode);
      }
    });

    // Background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the device's FCM token (optional for sending notifications)
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  }


  // Background handler for Firebase messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(); // Initialize Firebase when app is in the background
    print('Handling a background message: ${message.messageId}');

    if (message.notification != null) {
      // Print when a notification is received in the background
      print('Received a background notification: ${message.notification!.title}, ${message.notification!.body}');

      // Show a local notification when a message is received in the background
      FlutterLocalNotificationsPlugin().show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            playSound: true,
            channelShowBadge: true,
          ),
        ),
      );
    }
  }


  // Show local notification
  Future<void> _showLocalNotification(
      RemoteNotification notification, int id) async {
    await flutterLocalNotificationsPlugin.show(
      id, // Use the notification ID from the API
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          playSound: true,
          channelShowBadge: true,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Fetch notifications from API (same as before)
  Future<void> _fetchNotifications() async {
    try {
      final String? token = await _storage.read(key: 'AccessToken');

      if (token == null) {
        print('Token not found');
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse('https://posapi.lakhanisolution.com/api/App/GetCompanyNotification?Company_Id=1'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> notifications = data['result'][0]; // Assuming response contains a list

        // Loop through all notifications
        for (var notification in notifications) {
          int id = notification['Notification_Id'];

          // Check if the notification has already been shown
          if (_shownNotificationIds.contains(id.toString())) continue; // Skip if already shown

          // Add to the shown notification set
          _shownNotificationIds.add(id.toString());

          String title = notification['Notification_Type'] ?? 'No Title';
          String body = notification['Notification_Msg'] ?? 'No Message';
          String datetime = notification['Notification_Datetime'] ?? '';
          String fullBody = '$body\n\nReceived on: $datetime';

          // Add to the UI list
          setState(() {
            _notifications.add({'title': title, 'body': fullBody});
          });

          // Show local notification
          await flutterLocalNotificationsPlugin.show(
            id, // Unique ID for the notification
            title, // Notification title
            body, // Notification body
            NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelName,
                importance: Importance.high,
                playSound: true,
                channelShowBadge: true,
                priority: Priority.high,
              ),
            ),
          );
        }
      } else {
        print('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }


  @override
  void dispose() {
    _timer.cancel();
    _notificationStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'Notifications'),),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 5, // Reduced elevation for a floating effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        toolbarHeight: 60,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.blue[800],
                          size: 28,
                        ),
                        title: Text(
                          notification['title'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        subtitle: Text(
                          notification['body'] ?? '',
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                        onTap: () {
                          // Handle notification tap
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification details screen (for tapped notifications)
class NotificationDetailsScreen extends StatelessWidget {
  final String payload;

  NotificationDetailsScreen({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Details')),
      body: Center(
        child: Text(
          'Payload: $payload',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
