import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/routes/app_routes.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _authController = Get.find<AuthController>();
  final _profileController = Get.find<ProfileController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final RxBool _obscurePassword = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Please enter a valid email address.', isError: true);
      return false;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    final message = await _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (message == null) {
      await _syncOnboardingDraft();
      _showMessage('Logged in successfully.');
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    _showMessage(message, isError: true);
  }

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();

    final message = await _authController.continueWithGoogle();
    if (!mounted) return;

    if (message == null) {
      await _syncOnboardingDraft();
      _showMessage('Signed in with Google.');
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    if (message == AuthController.googleCancelledMessage) {
      _showMessage(message);
      return;
    }

    _showMessage(message, isError: true);
  }

  void _showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _syncOnboardingDraft() async {
    try {
      await _profileController.syncOnboardingDraftIfAny();
    } catch (_) {
      // Do not block auth flow if profile sync fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? theme.scaffoldBackgroundColor : const Color(0xFFeeeef2),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                margin: const EdgeInsets.fromLTRB(20, 50, 20, 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? colorScheme.surface
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black54
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Text(
                      "Welcome Back to LifeOS",
                      style: GoogleFonts.nunito(
                        color: colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Enter your email to sign in to your account",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        fillColor: isDark
                            ? colorScheme.surface
                            : Colors.grey.shade50,
                        filled: true,
                        prefixIcon: Icon(Icons.email_outlined,
                            color: colorScheme.primary),
                        hintText: "name@example.com",
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark
                                ? colorScheme.outline
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Obx(
                      () => TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword.value,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          fillColor: isDark
                              ? colorScheme.surface
                              : Colors.grey.shade50,
                          filled: true,
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: colorScheme.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obscurePassword.value = !_obscurePassword.value;
                            },
                            icon: Icon(
                              _obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: isDark
                                  ? colorScheme.outline
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.resetPassword),
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.nunito(
                              color: colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Obx(
                      () => TextButton.icon(
                        onPressed: _authController.isLoading.value ? null : _login,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(250, 60),
                          backgroundColor: colorScheme.primary,
                        ),
                        icon: _authController.isLoading.value
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(Icons.login_rounded,
                                size: 22, color: colorScheme.onPrimary),
                        label: Text(
                          _authController.isLoading.value ? 'Please wait...' : 'Login',
                          style: GoogleFonts.nunito(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),


                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? colorScheme.outline
                                : Colors.grey.shade400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Or Continue with",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? colorScheme.outline
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),


                    Obx(
                      () => TextButton.icon(
                        onPressed:
                            _authController.isLoading.value ? null : _continueWithGoogle,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(250, 52),
                          backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
                          side: BorderSide(
                            color: isDark ? colorScheme.outline : Colors.grey.shade300,
                          ),
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                          size: 20,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.raleway(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),


                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.signup);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(250, 50),
                        backgroundColor: isDark
                            ? colorScheme.surface
                            : Colors.grey.shade100,
                        side: BorderSide(
                          color: isDark
                              ? colorScheme.outline
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        "Create an account",
                        style: GoogleFonts.raleway(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),


              Text(
                "Manage Your Entire Life in One Place",
                style: GoogleFonts.raleway(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

