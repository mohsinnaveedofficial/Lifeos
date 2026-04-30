import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/routes/app_routes.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxBool _showPasswordRules = false.obs;

  final RxBool _hasLength = false.obs;
  final RxBool _hasUppercase = false.obs;
  final RxBool _hasLowercase = false.obs;
  final RxBool _hasNumber = false.obs;
  final RxBool _hasSpecial = false.obs;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      final text = _passwordController.text;
      _showPasswordRules.value = text.isNotEmpty;
      _checkPasswordStrength(text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String value) {
    _hasLength.value = value.length >= 8;
    _hasUppercase.value = RegExp(r'[A-Z]').hasMatch(value);
    _hasLowercase.value = RegExp(r'[a-z]').hasMatch(value);
    _hasNumber.value = RegExp(r'[0-9]').hasMatch(value);
    _hasSpecial.value = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
  }

  bool get _isPasswordValid =>
      _hasLength.value &&
      _hasUppercase.value &&
      _hasLowercase.value &&
      _hasNumber.value &&
      _hasSpecial.value;

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Please enter a valid email address.', isError: true);
      return false;
    }

    if (!_isPasswordValid) {
      _showMessage('Password does not meet security requirements.', isError: true);
      return false;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    final message = await _authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (message == null) {
      _showMessage('Account created successfully.');
      Get.offAllNamed(AppRoutes.personalize);
      return;
    }

    _showMessage(message, isError: true);
  }

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();

    final message = await _authController.continueWithGoogle();
    if (!mounted) return;

    if (message == null) {
      _showMessage('Signed in with Google.');
      Get.offAllNamed(AppRoutes.personalize);
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFEEEef2),
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
                  color: isDark ? colorScheme.surface : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.black.withValues(alpha: 0.1),
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
                      'Create Account',
                      style: GoogleFonts.nunito(
                        color: colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email below to create your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                        fillColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                        filled: true,
                        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                        hintText: 'name@example.com',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? colorScheme.outline : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.5),
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
                          fillColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                          filled: true,
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obscurePassword.value = !_obscurePassword.value;
                            },
                            icon: Icon(
                              _obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: isDark ? colorScheme.outline : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword.value,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          fillColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                          filled: true,
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
                            },
                            icon: Icon(
                              _obscureConfirmPassword.value ? Icons.visibility_off : Icons.visibility,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: isDark ? colorScheme.outline : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                          () => _showPasswordRules.value
                          ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password Requirements',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildPasswordRequirement(
                                  _hasLength.value,
                                  'At least 8 characters',
                                  colorScheme,
                                ),
                                const SizedBox(height: 4),
                                _buildPasswordRequirement(
                                  _hasUppercase.value,
                                  'One uppercase letter',
                                  colorScheme,
                                ),
                                const SizedBox(height: 4),
                                _buildPasswordRequirement(
                                  _hasLowercase.value,
                                  'One lowercase letter',
                                  colorScheme,
                                ),
                                const SizedBox(height: 4),
                                _buildPasswordRequirement(
                                  _hasNumber.value,
                                  'One number',
                                  colorScheme,
                                ),
                                const SizedBox(height: 4),
                                _buildPasswordRequirement(
                                  _hasSpecial.value,
                                  'One special character (!@#\$%^&*)',
                                  colorScheme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                          : const SizedBox.shrink(),
                    ),

                    Obx(
                      () => TextButton.icon(
                        onPressed: _authController.isLoading.value ? null : _register,
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
                            : Icon(
                                Icons.person_add_alt_outlined,
                                size: 22,
                                color: colorScheme.onPrimary,
                              ),
                        label: Text(
                          _authController.isLoading.value ? 'Please wait...' : 'Sign Up',
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
                            color: isDark ? colorScheme.outline : Colors.grey.shade400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Or Continue with',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? colorScheme.outline : Colors.grey.shade400,
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
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(250, 50),
                        backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
                        side: BorderSide(
                          color: isDark ? colorScheme.outline : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Already have an account? Login',
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
                'Manage Your Entire Life in One Place',
                style: GoogleFonts.raleway(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(bool met, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        if (met)
          const Icon(Icons.check_circle, size: 14, color: Colors.green)
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
