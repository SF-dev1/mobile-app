import 'dart:convert';

class WebhookConfig {
  String url;
  String method; // e.g., 'POST', 'GET'
  Map<String, String> headers;

  WebhookConfig({
    required this.url,
    this.method = 'POST',
    this.headers = const {},
  });

  // Factory constructor to create a WebhookConfig from a map (e.g., from JSON)
  factory WebhookConfig.fromJson(Map<String, dynamic> json) {
    return WebhookConfig(
      url: json['url'] as String? ?? '',
      method: json['method'] as String? ?? 'POST',
      headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
    );
  }

  // Method to convert a WebhookConfig instance to a map (e.g., for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'method': method,
      'headers': headers,
    };
  }

  // Helper to encode to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Helper to decode from JSON string
  static WebhookConfig fromJsonString(String jsonString) {
    if (jsonString.isEmpty) {
      return WebhookConfig(url: ''); // Return default/empty config
    }
    try {
      return WebhookConfig.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      print("Error decoding WebhookConfig from JSON string: $e");
      return WebhookConfig(url: ''); // Return default/empty on error
    }
  }
}
