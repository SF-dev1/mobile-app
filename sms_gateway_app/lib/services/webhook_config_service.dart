import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_gateway_app/models/webhook_config.dart';

class WebhookConfigService {
  static const String _configKey = 'webhook_config';

  Future<void> saveConfig(WebhookConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final String configJson = config.toJsonString();
    await prefs.setString(_configKey, configJson);
    print("Webhook config saved: $configJson");
  }

  Future<WebhookConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final String? configJson = prefs.getString(_configKey);
    if (configJson != null && configJson.isNotEmpty) {
      print("Webhook config loaded: $configJson");
      return WebhookConfig.fromJsonString(configJson);
    }
    print("No webhook config found, returning default.");
    return WebhookConfig(url: ''); // Return a default/empty config if none is saved
  }
}
