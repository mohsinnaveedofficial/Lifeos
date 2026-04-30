import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lifeos/bindings/app_binding.dart';
import 'package:lifeos/config/app_config.dart';
import 'package:lifeos/controllers/theme_controller.dart';
import 'package:lifeos/firebase_options.dart';
import 'package:lifeos/config/firebase_config.dart';
import 'package:lifeos/services/notification_service.dart';
import 'package:lifeos/services/startup_service.dart';
import 'package:lifeos/routes/app_pages.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final envOptions = loadFirebaseOptionsFromEnv();
      await Firebase.initializeApp(
        options: envOptions ?? DefaultFirebaseOptions.currentPlatform,
      );


      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(ThemeController.themeKey) ?? 'dark';
      final initialThemeMode =
          savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
      if (!Get.isRegistered<ThemeController>()) {
        Get.put(
          ThemeController(initialMode: initialThemeMode),
          permanent: true,
        );
      }

      final startupService = StartupService();
      await startupService.init();
      if (!Get.isRegistered<StartupService>()) {
        Get.put(startupService, permanent: true);
      }


      await NotificationService().init();

      if (kDebugMode && !AppConfig.hasApiBaseUrl) {
        debugPrint(
          'API_BASE_URL is empty. Provide --dart-define=API_BASE_URL for API-enabled builds.',
        );
      }

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
        return const Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Something went wrong. Please restart the app.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      };

      runApp(const MyApp());
    },
    (error, stack) async {
      try {
        await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {
        // ignore errors when reporting
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController(), permanent: true);

    return Obx(
      () => GetMaterialApp(
        title: 'LifeOS',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E3A8A),
            onPrimary: Colors.white,
            secondary: Color(0xFF22C55E),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF111827),
            error: Color(0xFFEF4444),
            onError: Colors.white,
            outline: Colors.black45,
            tertiary: Color(0xFFDBEAFE),
            onTertiary: Color(0xFF1E3A8A),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE5E7EB),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
            secondary: Color(0xFF22C55E),
            onSecondary: Colors.white,
            surface: Color(0xFF1E293B),
            onSurface: Color(0xFFF8FAFC),
            error: Color(0xFFEF4444),
            onError: Colors.white,
            outline: Color(0xFF6E91AC),
            tertiary: Color(0xFF1E293B),
            onTertiary: Color(0xFFF8FAFC),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E293B),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFF334155),
          ),
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        initialBinding: AppBinding(),
      ),
    );
  }
}
