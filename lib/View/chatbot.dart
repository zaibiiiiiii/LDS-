import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
@override
_ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final TextEditingController _controller = TextEditingController();
List<Map<String, String>> messages = [];
final String apiKey = "5PWJDRWMU5DIMQR5HV3TEJHDDGXOVRFM"; // Replace with your Wit.ai API Key
final String apiUrl = "https://api.wit.ai/message?v=20230101&q=";

Future<String> getBotResponse(String userMessage) async {
  final url = Uri.parse('$apiUrl$userMessage');
  final headers = {
    "Authorization": "Bearer $apiKey",  // Include your API key
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);

    // Extract the intent from the API response
    final intent = responseData['intents'] != null && responseData['intents'].isNotEmpty
        ? responseData['intents'][0]['name']       : null;

    // You can define a custom response based on the intent
    if (intent == 'greet') {
      return "Hello! How can I assist you today?";
    } else if (intent == 'goodbye') {
      return "Goodbye! Take care!";
    } else {
      return "I didn't quite understand that. Could you please rephrase?";
    }
  } else {
    throw Exception("Failed to fetch response: ${response.body}");
  }
}

void sendMessage(String message) async {
  setState(() {
    messages.add({'role': 'user', 'content': message});
  });

  try {
    final response = await getBotResponse(message);
    setState(() {
      messages.add({'role': 'bot', 'content': response});
    });
  } catch (e) {
    setState(() {
      messages.add({'role': 'bot', 'content': 'Error: $e'});
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Wit.ai Chatbot')),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isUser = msg['role'] == 'user';
              return ListTile(
                title: Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg['content']!),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Type a message'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    sendMessage(_controller.text);
                    _controller.clear();
                  }
                },
              )
            ],
          ),
        ),
      ],
    ),
  );
}
}