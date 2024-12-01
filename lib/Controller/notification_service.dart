import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lds/Models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void _showInAppNotification(RemoteMessage message) async {
  print('Showing in-app notification: ${message.notification?.title}');

  final prefs = await SharedPreferences.getInstance();
  List<String> storedNotifications = prefs.getStringList('notifications') ?? [];

  // Add new notification
  NotificationModel newNotification = NotificationModel(
    title: message.notification?.title ?? 'No Title',
    body: message.notification?.body ?? 'No Body',
    timestamp: DateTime.now(),
  );

  storedNotifications.add(jsonEncode(newNotification.toJson()));

  await prefs.setStringList('notifications', storedNotifications);

  print('Stored Notifications: $storedNotifications');
}
