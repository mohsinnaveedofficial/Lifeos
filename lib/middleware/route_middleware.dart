import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/auth_service.dart';
import 'package:lifeos/services/startup_service.dart';

class RouteMiddleware extends GetMiddleware {
  RouteMiddleware();

  static const Set<String> _publicRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.welcome,
    AppRoutes.healthWalkthrough,
    AppRoutes.financeWalkthrough,
    AppRoutes.productivityWalkthrough,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.resetPassword,
  };

  @override
  RouteSettings? redirect(String? route) {
    bool isAuthenticated = false;

    try {
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        isAuthenticated = authService.currentUser != null;
      }
    } catch (e) {
      debugPrint('[GetX] auth check skipped: $e');
    }

    debugPrint('[GetX] route: $route, authenticated: $isAuthenticated');

    final startupService = Get.isRegistered<StartupService>()
        ? Get.find<StartupService>()
        : null;
    final onboardingCompleted = startupService?.onboardingCompleted ?? false;

    if (!isAuthenticated && route != null && !_publicRoutes.contains(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (isAuthenticated && !onboardingCompleted) {
      if (route == AppRoutes.personalize || route == AppRoutes.complete) {
        return null;
      }
      return const RouteSettings(name: AppRoutes.personalize);
    }

    final isAuthOrOnboardingRoute = route == AppRoutes.login ||
        route == AppRoutes.signup ||
        route == AppRoutes.resetPassword ||
        route == AppRoutes.welcome ||
        route == AppRoutes.healthWalkthrough ||
        route == AppRoutes.financeWalkthrough ||
        route == AppRoutes.productivityWalkthrough ||
        route == AppRoutes.personalize ||
        route == AppRoutes.complete;
    if (isAuthenticated && isAuthOrOnboardingRoute) {
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}
