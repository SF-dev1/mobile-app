import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_gateway_app/models/sms_message.dart';
import 'package:sms_gateway_app/models/webhook_config.dart';
import 'package:sms_gateway_app/services/webhook_config_service.dart';

class ApiService {
  // TODO: Replace with your actual primary SMS sending API endpoint
  static const String _primaryApiEndpoint = 'https://api.example.com/send_sms';
  // TODO: Replace with your actual API key or token for the primary API
  static const String _primaryApiKey = 'YOUR_PRIMARY_API_KEY';

  final WebhookConfigService _webhookConfigService = WebhookConfigService();

  Future<bool> sendSmsAndNotifyWebhook(SmsMessage message) async {
    bool primarySendSuccess = false;
    try {
      // Step 1: Send SMS via the primary API
      final response = await http.post(
        Uri.parse(_primaryApiEndpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // Example header authentication for primary API
          'X-Api-Key': _primaryApiKey,
        },
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Primary SMS sent successfully to ${message.to}: ${response.body}');
        primarySendSuccess = true;
      } else {
        print('Failed to send primary SMS. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        primarySendSuccess = false;
        // Optionally, decide if you want to stop here or still attempt webhook notification
        // For now, we'll only notify webhook if primary send was successful.
        return false;
      }
    } catch (e) {
      print('Error sending primary SMS: $e');
      primarySendSuccess = false;
      return false; // Stop if primary sending fails
    }

    // Step 2: If primary SMS send was successful, notify the configured webhook
    if (primarySendSuccess) {
      try {
        WebhookConfig webhookConfig = await _webhookConfigService.loadConfig();
        if (webhookConfig.url.isNotEmpty && Uri.tryParse(webhookConfig.url)?.isAbsolute == true) {

          // Prepare payload for the webhook
          // You might want to customize this payload
          final webhookPayload = {
            'sent_to': message.to,
            'body': message.body,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'sent', // Or any other status info you have
          };

          // Add custom headers from webhookConfig
          Map<String, String> webhookHeaders = {
            'Content-Type': 'application/json; charset=UTF-8',
            ...webhookConfig.headers, // Add user-defined headers
          };

          print('Sending notification to webhook: ${webhookConfig.url}');
          print('Webhook payload: ${jsonEncode(webhookPayload)}');
          print('Webhook headers: $webhookHeaders');

          final webhookResponse = await http.post( // Or use webhookConfig.method
            Uri.parse(webhookConfig.url),
            headers: webhookHeaders,
            body: jsonEncode(webhookPayload),
          );

          if (webhookResponse.statusCode >= 200 && webhookResponse.statusCode < 300) {
            print('Webhook notification successful: ${webhookResponse.statusCode}');
          } else {
            print('Failed to notify webhook. Status code: ${webhookResponse.statusCode}');
            print('Webhook response body: ${webhookResponse.body}');
            // Decide if this failure should affect the overall success status.
            // For now, the function returns true if primary send was okay.
          }
        } else {
          print('No valid webhook URL configured or loaded. Skipping webhook notification.');
        }
      } catch (e) {
        print('Error sending notification to webhook: $e');
        // Decide if this failure should affect the overall success status.
      }
    }
    return primarySendSuccess; // Return status of the primary SMS sending operation
  }
}
