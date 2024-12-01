import 'package:flutter/material.dart';
import 'package:lds/Models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications = prefs.getStringList('notifications') ?? [];

    print('Loaded Notifications: $storedNotifications');

    setState(() {
      notifications = storedNotifications
          .map((data) => NotificationModel.fromJson(jsonDecode(data)))
          .toList()
          .reversed
          .toList(); // Show latest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text('No notifications yet.'),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.body),
            trailing: Text(
              '${notification.timestamp.hour}:${notification.timestamp.minute}, ${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}',
            ),
          );
        },
      ),
    );
  }
}
