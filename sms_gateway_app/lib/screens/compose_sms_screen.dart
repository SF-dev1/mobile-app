import 'package:flutter/material.dart';
import 'package:sms_gateway_app/models/sms_message.dart';
import 'package:sms_gateway_app/services/api_service.dart';

class ComposeSmsScreen extends StatefulWidget {
  const ComposeSmsScreen({super.key});

  @override
  State<ComposeSmsScreen> createState() => _ComposeSmsScreenState();
}

class _ComposeSmsScreenState extends State<ComposeSmsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Renamed method and updated the call to ApiService
  Future<void> _sendSmsAndNotify() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final message = SmsMessage(
        to: _recipientController.text.trim(), // Added .trim()
        body: _messageController.text.trim(), // Added .trim()
      );

      // Corrected method call to ApiService
      final success = await _apiService.sendSmsAndNotifyWebhook(message);

      if (mounted) { // Check if mounted before further operations
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Updated SnackBar message for clarity
            content: Text(success ? 'SMS sent and webhook notified (if configured)!' : 'Failed to send SMS.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _recipientController.clear();
          _messageController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming AppBar is handled by MainScreen, so this widget is now just the body content.
    // If this screen can be pushed onto navigator independently, it might need its own Scaffold.
    // For use in IndexedStack within MainScreen, returning Padding is fine.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Phone Number',
                hintText: '+1234567890', // Added hintText
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) { // Added .trim()
                  return 'Please enter a recipient';
                }
                // Basic validation for phone number (can be improved)
                if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(value.trim())) { // Added .trim()
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) { // Added .trim()
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon( // Changed to ElevatedButton.icon for better UX
              icon: _isLoading
                  ? Container( // Custom progress indicator for icon button
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white, // Or use Theme.of(context).colorScheme.onPrimary
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'Sending...' : 'Send SMS & Notify Webhook'), // Updated button label
              onPressed: _isLoading ? null : _sendSmsAndNotify, // Updated to call renamed method
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
