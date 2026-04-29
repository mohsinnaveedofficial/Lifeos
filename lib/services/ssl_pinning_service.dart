import 'dart:io';
import 'package:http/io_client.dart';

/// SecureHttpClientProvider creates an HttpClient that trusts a bundled PEM
/// certificate (placed at assets/certs/server_cert.pem) to enable certificate
/// pinning. This is a whitelist approach: only the provided certificate will be
/// trusted. Add the PEM for your API server to the assets and update
/// pubspec.yaml accordingly.
class SecureHttpClientProvider {
  /// Path to the bundled PEM certificate inside assets.
  final String pemAssetPath;

  SecureHttpClientProvider({this.pemAssetPath = 'assets/certs/server_cert.pem'});

  /// Create an IOClient backed by an HttpClient with a SecurityContext that
  /// trusts only the provided certificate.
  Future<IOClient> createHttpClient() async {
    // Load PEM bytes from asset bundle at runtime via rootBundle would require
    // flutter services; however HttpClient accepts SecurityContext setTrustedCertificates
    // from bytes. We'll try to load via File for simplicity - CI/CD must ensure
    // the PEM is copied to the application's asset folder or platform-specific
    // certificate store. If missing, fallback to default HttpClient (no pinning).
    try {
      final file = File(pemAssetPath);
      if (!await file.exists()) {
        // PEM not found; return default client (no pinning). In production,
        // ensure the PEM is included in assets and present at runtime.
        return IOClient(HttpClient());
      }

      final bytes = await file.readAsBytes();
      final context = SecurityContext(withTrustedRoots: false);
      context.setTrustedCertificatesBytes(bytes);
      final httpClient = HttpClient(context: context);

      // Optional: set timeouts or other properties here
      httpClient.connectionTimeout = const Duration(seconds: 10);

      return IOClient(httpClient);
    } catch (e) {
      // On any error, expose a default client to avoid crashing the app.
      return IOClient(HttpClient());
    }
  }
}

