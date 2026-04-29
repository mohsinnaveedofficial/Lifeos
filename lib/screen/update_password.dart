import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifeos/controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final RxBool _isUpdating = false.obs;
  final RxBool _showSuccess = false.obs;

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final RxBool _obscureCurrent = true.obs;
  final RxBool _obscureNew = true.obs;
  final RxBool _obscureConfirm = true.obs;

  final RxBool _hasLength = false.obs;
  final RxBool _hasUppercase = false.obs;
  final RxBool _hasLowercase = false.obs;
  final RxBool _hasNumber = false.obs;
  final RxBool _hasSpecial = false.obs;

  final RxString _currentPassword = ''.obs;
  final RxString _newPassword = ''.obs;
  final RxString _confirmPassword = ''.obs;

  @override
  void initState() {
    super.initState();
    _currentController.addListener(() {
      _currentPassword.value = _currentController.text;
    });
    _newController.addListener(() {
      _newPassword.value = _newController.text;
      _checkPasswordStrength(_newController.text);
    });
    _confirmController.addListener(() {
      _confirmPassword.value = _confirmController.text;
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
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

  bool get _passwordsMatch =>
      _newPassword.value.isNotEmpty && _newPassword.value == _confirmPassword.value;

  Future<void> _handleUpdate() async {
    if (_currentPassword.value.isEmpty ||
        _newPassword.value.isEmpty ||
        _confirmPassword.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords don't match")),
      );
      return;
    }

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password doesn't meet security requirements")),
      );
      return;
    }

    _isUpdating.value = true;

    final message = await _authController.changePassword(
      currentPassword: _currentPassword.value,
      newPassword: _newPassword.value,
    );

    if (!mounted) return;

    if (message != null) {
      _isUpdating.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    if (mounted) {
      _isUpdating.value = false;
      _showSuccess.value = true;

      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      _checkPasswordStrength("");

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final mutedColor = colorScheme.outline.withOpacity(0.1);
    final borderColor = colorScheme.outline;
    final mutedTextColor = colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back,
                          size: 24, color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface),
                      ),
                      Text(
                        "Update your account password",
                        style: TextStyle(fontSize: 14, color: mutedTextColor),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withOpacity(0.2),
                          Colors.teal.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Icon(Icons.shield_outlined,
                        size: 48, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_showSuccess.value)
                FadeSlideTransition(
                  delay: 0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Password Updated!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green)),
                              Text("Your password has been changed successfully.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              FadeSlideTransition(
                delay: 0.1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        label: "Current Password",
                        controller: _currentController,
                        hint: "Enter current password",
                        obscureText: _obscureCurrent.value,
                        onToggleVisibility: () =>
                            _obscureCurrent.value = !_obscureCurrent.value,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        onChanged: (_) {},
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: "New Password",
                        controller: _newController,
                        hint: "Enter new password",
                        obscureText: _obscureNew.value,
                        onToggleVisibility: () =>
                            _obscureNew.value = !_obscureNew.value,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        onChanged: (_) {},
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: "Confirm New Password",
                        controller: _confirmController,
                        hint: "Confirm new password",
                        obscureText: _obscureConfirm.value,
                        onToggleVisibility: () =>
                            _obscureConfirm.value = !_obscureConfirm.value,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        onChanged: (_) {},
                        colorScheme: colorScheme,
                      ),
                      if (_confirmPassword.value.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _passwordsMatch ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: _passwordsMatch
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _passwordsMatch
                                  ? "Passwords match"
                                  : "Passwords don't match",
                              style: TextStyle(
                                fontSize: 14,
                                color: _passwordsMatch
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_newPassword.value.isNotEmpty) ...[
                const SizedBox(height: 16),
                FadeSlideTransition(
                  delay: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password Requirements",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface)),
                        const SizedBox(height: 12),
                        _PasswordRequirement(
                            met: _hasLength.value,
                            text: "At least 8 characters"),
                        const SizedBox(height: 8),
                        _PasswordRequirement(
                            met: _hasUppercase.value,
                            text: "One uppercase letter"),
                        const SizedBox(height: 8),
                        _PasswordRequirement(
                            met: _hasLowercase.value,
                            text: "One lowercase letter"),
                        const SizedBox(height: 8),
                        _PasswordRequirement(
                            met: _hasNumber.value, text: "One number"),
                        const SizedBox(height: 8),
                        _PasswordRequirement(
                            met: _hasSpecial.value,
                            text: "One special character (!@#\$%^&*)"),
                        if (_isPasswordValid) ...[
                          const SizedBox(height: 12),
                          Divider(color: borderColor),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text("Strong password!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0.2,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isUpdating.value ||
                                !_isPasswordValid ||
                                !_passwordsMatch ||
                                _currentPassword.value.isEmpty)
                            ? null
                            : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withOpacity(0.5),
                          disabledForegroundColor: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isUpdating.value
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text("Updating...",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text("Update Password",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: borderColor),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0.3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 14, color: Colors.orange, height: 1.5),
                      children: const [
                        TextSpan(text: "🔒 "),
                        TextSpan(
                            text: "Security Tip: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                "Use a unique password that you don't use on other websites. Consider using a password manager."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required Color mutedColor,
    required Color borderColor,
    required Color primaryColor,
    required ValueChanged<String> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: mutedColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final bool met;
  final String text;

  const _PasswordRequirement({Key? key, required this.met, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (met)
          const Icon(Icons.check_circle, size: 16, color: Colors.green)
        else
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.4), width: 2),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: met ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final double delay;

  const FadeSlideTransition({Key? key, required this.child, required this.delay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, double value, childWidget) {
        double adjustedValue =
            (value - delay).clamp(0.0, 1.0) * (1 / (1 - delay).clamp(0.1, 1.0));

        return Opacity(
          opacity: adjustedValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - adjustedValue)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
