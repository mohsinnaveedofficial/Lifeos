import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/auth_service.dart';
import 'package:lifeos/services/startup_service.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  StartupService get _startupService => Get.isRegistered<StartupService>()
      ? Get.find<StartupService>()
      : StartupService();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isAuthenticated =
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().currentUser != null;

    final isOnboardingCompleted = Get.isRegistered<StartupService>()
        ? _startupService.onboardingCompleted
        : await _startupService.isOnboardingCompleted();

    if (!isOnboardingCompleted) {
      Get.offNamed(isAuthenticated ? AppRoutes.personalize : AppRoutes.welcome);
      return;
    }

    Get.offNamed(isAuthenticated ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Colors.blue[600]!,
              Colors.indigo[900]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(height: 100, width: 70),
                Positioned(
                  bottom: 10,
                  child: Image.asset(
                    'assets/icons/icon_bg.png',
                    color: Colors.white,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.dashboard_outlined,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "LifeOS",
              style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 5),
            Text(
              "Manage Your Entire Life in One Place",
              style: GoogleFonts.raleway(
                  color: Color(0xFFB6CDFB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}
