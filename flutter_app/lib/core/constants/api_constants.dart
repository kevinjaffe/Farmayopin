class ApiConstants {
  static const String _defaultUrl = 'http://localhost:8080';

  static String get baseUrl {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    return configured.isNotEmpty ? configured : _defaultUrl;
  }

  static String get baseUrlForDevice => baseUrl;
}
