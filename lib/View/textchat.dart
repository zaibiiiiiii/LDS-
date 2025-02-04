import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('wss://d32d-111-88-100-180.ngrok-free.app'),
  );

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    notificationsPlugin.initialize(initializationSettings);

    _channel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message);
        String content = "";
        String timestamp = "";

        if (decodedMessage is Map && decodedMessage.containsKey("type")) {
          if (decodedMessage["type"] == "history") {
            List<dynamic> history = decodedMessage["data"];
            for (var msg in history) {
              messages.add(ChatMessage(
                  content: msg["content"],
                  isCurrentUser: false,
                  timestamp: msg["timestamp"]));
            }
          } else if (decodedMessage["type"] == "message") {
            if (decodedMessage["content"] is Map &&
                decodedMessage["content"].containsKey("data")) {
              // Decode the buffer data
              final List<int> data =
              List<int>.from(decodedMessage["content"]["data"]);
              content = utf8.decode(data); // Decode from UTF-8
            } else if (decodedMessage["content"] is String) {
              content = decodedMessage["content"];
            } else {
              print("Unexpected content format: ${decodedMessage["content"]}");
              content = "Error: Unexpected message format"; // Or handle it differently
            }
            timestamp = DateTime.now().toIso8601String();
            messages.add(ChatMessage(
                content: content, isCurrentUser: false, timestamp: timestamp));
          }
        } else {
          content = message;
          timestamp = DateTime.now().toIso8601String();
          messages.add(ChatMessage(
              content: content, isCurrentUser: false, timestamp: timestamp));
        }
        setState(() {}); // Important: Call setState to rebuild the UI

        notificationsPlugin.show(
          0,
          'New Message',
          content,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Chat Notifications',
              channelDescription: 'Notifications for new chat messages',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      } catch (e) {
        print("Error decoding message: $e");
        print("Raw message: $message");
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now();
      final  formattedTime = DateFormat('HH:mm').format(now);
      String message = _controller.text;
      _channel.sink.add(message);
      setState(() {
        messages.add(ChatMessage(
          content: message,
          isCurrentUser: true,
          timestamp: now.toIso8601String(),
        ));
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Chat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: messages[index]);
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: 'Type a message...',
                contentPadding:
                EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String content;
  final bool isCurrentUser;
  final String timestamp;

  ChatMessage(
      {required this.content,
        required this.isCurrentUser,
        required this.timestamp});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.parse(message.timestamp);
    final formattedTime = DateFormat('HH:mm').format(dateTime);

    return Align(
      alignment: message.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: message.isCurrentUser ? Colors.teal[100] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
