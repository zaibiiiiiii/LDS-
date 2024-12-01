class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({required this.title, required this.body, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
