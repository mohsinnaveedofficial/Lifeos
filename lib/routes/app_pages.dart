import 'package:get/get.dart';
import 'package:lifeos/middleware/route_middleware.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/startup_service.dart';
import 'package:lifeos/screen/HomeScreen.dart';
import 'package:lifeos/screen/auth/forget_password.dart';
import 'package:lifeos/screen/auth/login.dart';
import 'package:lifeos/screen/auth/signup.dart';
import 'package:lifeos/screen/dashboard.dart';
import 'package:lifeos/screen/edit_Profile.dart';
import 'package:lifeos/screen/emergency_Mode.dart';
import 'package:lifeos/screen/finance.dart';
import 'package:lifeos/screen/focus.dart';
import 'package:lifeos/screen/goal.dart';
import 'package:lifeos/screen/health.dart';
import 'package:lifeos/screen/health_analytics.dart';
import 'package:lifeos/screen/journal.dart';
import 'package:lifeos/screen/mentall_Wellness.dart';
import 'package:lifeos/screen/notification.dart';
import 'package:lifeos/screen/onboarding/complete.dart';
import 'package:lifeos/screen/onboarding/personalize.dart';
import 'package:lifeos/screen/splash.dart';
import 'package:lifeos/screen/task.dart';
import 'package:lifeos/screen/update_password.dart';
import 'package:lifeos/screen/walkthrough/finance_walkthrough.dart';
import 'package:lifeos/screen/walkthrough/health_walkthrough.dart';
import 'package:lifeos/screen/walkthrough/productivity_walkthrough.dart';
import 'package:lifeos/screen/walkthrough/welcome_screen.dart';

class AppPages {
  static final _middlewares = <GetMiddleware>[RouteMiddleware()];
  static StartupService get _startupService => Get.find<StartupService>();

  static void _skipOnboarding() async {
    await _startupService.markOnboardingCompleted();
    Get.offAllNamed(AppRoutes.login);
  }

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const Splash(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeScreen(
        onGetStarted: () => Get.offNamed(AppRoutes.healthWalkthrough),
        onSkip: _skipOnboarding,
      ),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.healthWalkthrough,
      page: () => HealthWalkthrough(
        onFinish: () => Get.toNamed(AppRoutes.financeWalkthrough),
        onSkip: _skipOnboarding,
      ),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.financeWalkthrough,
      page: () => FinanceWalkthrough(
        onNext: () => Get.toNamed(AppRoutes.productivityWalkthrough),
        onSkip: _skipOnboarding,
      ),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.productivityWalkthrough,
      page: () => ProductivityWalkthrough(
        onNext: () => Get.offNamed(AppRoutes.personalize),
        onSkip: _skipOnboarding,
      ),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.personalize,
      page: () => const Personalize(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.complete,
      page: () => const Complete(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const Login(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const Signup(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Homescreen(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.finance,
      page: () => const Finance(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.task,
      page: () => const Task(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.health,
      page: () => const Health(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.healthAnalytics,
      page: () => const HealthAnalyticsPage(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.mentalWellness,
      page: () => const MentalWellness(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.focus,
      page: () => const FocusTimerPage(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.goals,
      page: () => const Goals(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.journal,
      page: () => const Journal(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      middlewares: _middlewares,
    ),
    GetPage(
      name: AppRoutes.emergency,
      page: () => const EmergencyMode(),
      middlewares: _middlewares,
    ),
  ];
}