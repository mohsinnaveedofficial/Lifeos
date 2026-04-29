import 'package:firebase_core/firebase_core.dart';

/// Loads FirebaseOptions from compile-time environment (dart-define).
/// Define these values during build or CI using --dart-define=FIREBASE_API_KEY=... etc.
FirebaseOptions? loadFirebaseOptionsFromEnv() {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  if (apiKey.isEmpty || appId.isEmpty || projectId.isEmpty) {
    return null;
  }

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId.isEmpty ? '' : messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket.isEmpty ? '' : storageBucket,
    authDomain: authDomain.isEmpty ? '' : authDomain,
    measurementId: measurementId.isEmpty ? '' : measurementId,
  );
}


