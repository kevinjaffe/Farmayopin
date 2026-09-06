import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _defaultUrl = 'http://localhost:8080';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8080';

  static String get baseUrl {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (configured.isNotEmpty) return configured;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorUrl;
    }

    return _defaultUrl;
  }

  static String get baseUrlForDevice => baseUrl;
}
