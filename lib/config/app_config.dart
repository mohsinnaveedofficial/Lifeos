class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const bool enforcePinnedCertificates = bool.fromEnvironment(
    'ENFORCE_SSL_PINNING',
    defaultValue: false,
  );

  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}

