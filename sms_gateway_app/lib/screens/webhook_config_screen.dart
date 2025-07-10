import 'package:flutter/material.dart';
import 'package:sms_gateway_app/models/webhook_config.dart';
import 'package:sms_gateway_app/services/webhook_config_service.dart';

class WebhookConfigScreen extends StatefulWidget {
  const WebhookConfigScreen({super.key});

  @override
  State<WebhookConfigScreen> createState() => _WebhookConfigScreenState();
}

class _WebhookConfigScreenState extends State<WebhookConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final WebhookConfigService _configService = WebhookConfigService();
  late WebhookConfig _currentConfig;
  bool _isLoading = true;

  final _urlController = TextEditingController();
  String _selectedMethod = 'POST';
  final List<TextEditingController> _headerKeyControllers = [];
  final List<TextEditingController> _headerValueControllers = [];

  final List<String> _httpMethods = ['POST', 'GET', 'PUT', 'PATCH', 'DELETE'];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    _currentConfig = await _configService.loadConfig();
    _urlController.text = _currentConfig.url;
    _selectedMethod = _currentConfig.method;

    _headerKeyControllers.clear();
    _headerValueControllers.clear();
    _currentConfig.headers.forEach((key, value) {
      _headerKeyControllers.add(TextEditingController(text: key));
      _headerValueControllers.add(TextEditingController(text: value));
    });

    setState(() => _isLoading = false);
  }

  void _addHeaderField() {
    setState(() {
      _headerKeyControllers.add(TextEditingController());
      _headerValueControllers.add(TextEditingController());
    });
  }

  void _removeHeaderField(int index) {
    setState(() {
      _headerKeyControllers[index].dispose();
      _headerValueControllers[index].dispose();
      _headerKeyControllers.removeAt(index);
      _headerValueControllers.removeAt(index);
    });
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Important to trigger onSaved for FormFields if used

      Map<String, String> headers = {};
      for (int i = 0; i < _headerKeyControllers.length; i++) {
        final key = _headerKeyControllers[i].text.trim();
        final value = _headerValueControllers[i].text.trim();
        if (key.isNotEmpty) {
          headers[key] = value;
        }
      }

      final newConfig = WebhookConfig(
        url: _urlController.text.trim(),
        method: _selectedMethod,
        headers: headers,
      );

      await _configService.saveConfig(newConfig);
      _currentConfig = newConfig; // Update current config state

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Webhook configuration saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    for (var controller in _headerKeyControllers) {
      controller.dispose();
    }
    for (var controller in _headerValueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Webhook Configuration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhook Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://your-service.com/webhook',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) { // Added .trim()
                    return 'Please enter a Webhook URL';
                  }
                  // Corrected validation logic for absolute URI
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.isAbsolute) {
                     return 'Please enter a valid, absolute URL (e.g., http://example.com)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'HTTP Method',
                  border: OutlineInputBorder(),
                ),
                items: _httpMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMethod = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text('Custom Headers', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _headerKeyControllers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _headerKeyControllers[index],
                              decoration: const InputDecoration(labelText: 'Header Name'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _headerValueControllers[index],
                              decoration: const InputDecoration(labelText: 'Header Value'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _removeHeaderField(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Header'),
                onPressed: _addHeaderField,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
