import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/startup_service.dart';

class Complete extends StatefulWidget {
  const Complete({super.key});

  @override
  State<Complete> createState() => _CompleteState();
}

class _CompleteState extends State<Complete>
    with SingleTickerProviderStateMixin {
  final StartupService _startupService = Get.find<StartupService>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final RxString _greetingName = ''.obs;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
    _loadGreetingName();
  }

  Future<void> _loadGreetingName() async {
    try {
      final draft = await _profileController.readOnboardingDraft();
      final draftName = (draft['name'] as String? ?? '').trim();
      if (draftName.isNotEmpty) {
        if (!mounted) return;
        _greetingName.value = draftName;
        return;
      }
    } catch (_) {
      // Ignore draft read failures.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 60),

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Colors.blue[600]!, Colors.indigo[900]!],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(height: 130, width: 100),
                  Positioned(
                    top: 30,
                    right: 3,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.lightGreenAccent,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: 0,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.yellow,
                        size: 25,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.yellow,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Obx(
                () => Text(
                  _greetingName.value.isEmpty
                      ? "You're all set! 🎉"
                      : "You're all set, ${_greetingName.value}! 🎉",
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              SizedBox(height: 10),
              Text(
                "Your personal Life Operating System is ready to go",
                style: GoogleFonts.raleway(
                  color: Color(0xFFB6CDFB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text("🎯", style: TextStyle(fontSize: 30)),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Track goals and build lasting habits",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text("📊", style: TextStyle(fontSize: 30)),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Get personalized insights and analytics",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text("💪", style: TextStyle(fontSize: 30)),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Monitor your health and wellness",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text("💰", style: TextStyle(fontSize: 30)),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Manage your finances effectively",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text("🧘", style: TextStyle(fontSize: 30)),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Practice mindfulness and self-care",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextButton.icon(
                onPressed: () async {
                  try {
                    await _profileController.syncOnboardingDraftIfAny();
                  } catch (_) {
                    // Do not block onboarding completion if profile sync fails.
                  }
                  await _startupService.markOnboardingCompleted();
                  Get.offAllNamed(AppRoutes.home);
                },

                icon: Icon(
                  Icons.rocket_launch_outlined,
                  color: Colors.deepPurple,
                ),
                iconAlignment: IconAlignment.start,
                label: Text(
                  "Start Your Journey",
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(250, 60),
                ),
              ),
              SizedBox(height: 10),

              Text(
                "You can customize everything in Settings later",
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  color: Colors.blue.shade200,
                  fontWeight: FontWeight.w600,
                  decorationColor: Colors.blue.shade200,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
