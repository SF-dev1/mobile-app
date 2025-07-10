class SmsMessage {
  final String to;
  final String body;

  SmsMessage({required this.to, required this.body});

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'body': body,
    };
  }
}
