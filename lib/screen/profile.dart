import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/controllers/theme_controller.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/auth_service.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<void> _logout(AuthController authController) async {
    final message = await authController.logout();

    if (message == null) {
      Get.snackbar(
        'Success',
        'Logged out successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    final authService = Get.find<AuthService>();
    final themeController = Get.find<ThemeController>();

    if (profileController.profile.value == null &&
        !profileController.isLoading.value) {
      profileController.loadProfile();
    }


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Obx(() {
                final profile = profileController.profile.value;
                final photoUrl = profile?.photoUrl ?? '';

                return Stack(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 4,
                        ),
                        image: photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/images/avatar.jpg'),
                                fit: BoxFit.cover,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark ? 0.3 : 0.08,
                            ),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 12),

              Obx(() {
                final profileName = profileController.profile.value?.name.trim() ?? '';
                final authName = authService.currentUser?.displayName?.trim() ?? '';
                final email = authService.currentUser?.email?.trim() ?? '';
                final emailPrefix = email.contains('@') ? email.split('@').first : '';

                final name = profileName.isNotEmpty && profileName.toLowerCase() != 'user'
                    ? profileName
                    : (authName.isNotEmpty
                        ? authName
                        : (emailPrefix.isNotEmpty ? emailPrefix : 'User'));
                return Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                );
              }),

              const SizedBox(height: 4),

              Obx(() {
                final email = profileController.profile.value?.email ?? '';
                return Text(
                  email,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                );
              }),

              const SizedBox(height: 28),

              sectionTitle("ACCOUNT", context),
              const SizedBox(height: 12),

              settingsCard([
                settingTile(
                  context,
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  title: "Edit Profile",
                  onTap: () => Get.toNamed(AppRoutes.editProfile),
                ),
                settingTile(
                  context,
                  icon: Icons.shield_outlined,
                  color: Colors.green,
                  title: "Change Password",
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                settingTile(
                  context,
                  icon: Icons.notifications_none,
                  color: Colors.orange,
                  title: "Notifications",
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                  last: true,
                )
              ], context),

              const SizedBox(height: 22),

              sectionTitle("PREFERENCES", context),
              const SizedBox(height: 12),

              settingsCard([
                settingTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  color: Colors.purple,
                  title: "Dark Mode",
                  onTap: () {
                    final isDark = theme.brightness == Brightness.dark;
                    themeController.toggleTheme(!isDark);
                  },
                  trailing: Switch(
                    value: theme.brightness == Brightness.dark,
                    onChanged: (value) {
                      themeController.toggleTheme(value);
                    },
                    activeColor: colorScheme.primary,
                  ),
                ),
                settingTile(
                  context,
                  icon: Icons.phone_outlined,
                  color: colorScheme.error,
                  title: "Emergency Contacts",
                  last: true,
                  onTap: () => Get.toNamed(AppRoutes.emergency),
                ),
              ], context),

              const SizedBox(height: 30),

              Obx(
                () => InkWell(
                  onTap: authController.isLoading.value
                      ? null
                      : () => _logout(authController),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (authController.isLoading.value)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.error,
                              ),
                            ),
                          )
                        else
                          Icon(Icons.logout, color: colorScheme.error, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          authController.isLoading.value ? 'Logging out...' : 'Log Out',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                "Version 1.0.0 · LifeOS Inc.",
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget settingsCard(List<Widget> children, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.05,
            ),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget settingTile(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        VoidCallback? onTap,
        Widget? trailing,
        bool last = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.only(left: 68, right: 16),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}
