import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final RxBool _isSubmitted = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isLoading = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    _error.value = '';
    _isLoading.value = true;

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      _error.value = 'Please enter a valid email address';
      _isLoading.value = false;
      return;
    }

    final message = await _authController.resetPassword(email: email);

    if (!mounted) return;

    if (message == null) {
      _isSubmitted.value = true;
    } else {
      _error.value = message;
    }
    _isLoading.value = false;
  }

  void _handleBackToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 450),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: _isSubmitted.value
                          ? _buildSubmittedView(colorScheme, isDark)
                          : _buildFormView(colorScheme, isDark),
                    ),
                    if (!_isSubmitted.value) ...[
                      const SizedBox(height: 32),
                      Text(
                        '"Your Data Security is Our Priority"',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _handleBackToLogin,
            icon: Icon(
              Icons.arrow_back,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            label: Text(
              "Back to Login",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.mail_outline,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Reset Password",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your email address and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        if (_error.value.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        TextFormField(
          controller: _emailController,
          enabled: !_isLoading.value,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "name@example.com",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            prefixIcon: Icon(
              Icons.mail_outline,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surface
                : colorScheme.onSurface.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading.value ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: isDark ? 0 : 4,
            shadowColor: colorScheme.primary.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading.value
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Sending...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, size: 18),
              SizedBox(width: 8),
              Text(
                "Send Reset Link",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Need Help?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "If you don't receive the email within a few minutes, please check your spam folder or contact support.",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedView(ColorScheme colorScheme, bool isDark) {
    final blueBgColor = isDark ? Colors.blue.withOpacity(0.15) : Colors.blue.shade50;
    final blueBorderColor = isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade200;
    final blueTextColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;
    final blueMutedTextColor = isDark ? Colors.blue.shade300 : Colors.blue.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 32,
              color: isDark ? Colors.green.shade400 : Colors.green.shade600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Check Your Email",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent a password reset link to:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: blueBgColor,
            border: Border.all(color: blueBorderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: blueTextColor),
                  const SizedBox(width: 8),
                  Text(
                    "What to do next:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: blueTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStepItem("1.", "Check your email inbox", blueMutedTextColor),
              const SizedBox(height: 8),
              _buildStepItem("2.", "Click the reset link in the email", blueMutedTextColor),
              const SizedBox(height: 8),
              _buildStepItem("3.", "Create a new password", blueMutedTextColor),
              const SizedBox(height: 8),
              _buildStepItem("4.", "Login with your new password", blueMutedTextColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            children: [
              Text(
                "Didn't receive the email? ",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                "Check your spam folder or ",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _isSubmitted.value = false;
                },
                child: Text(
                  "try again",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Text(
                ".",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _handleBackToLogin,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 16, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                "Back to Login",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

