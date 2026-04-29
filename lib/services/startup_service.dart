import 'package:shared_preferences/shared_preferences.dart';

class StartupService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  bool _onboardingCompleted = false;

  bool get onboardingCompleted => _onboardingCompleted;

  Future<void> init() async {
    _onboardingCompleted = await isOnboardingCompleted();
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    return _onboardingCompleted;
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    _onboardingCompleted = true;
  }
}

