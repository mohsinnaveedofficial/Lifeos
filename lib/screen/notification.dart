import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifeos/controllers/profile_controller.dart';

class NotificationSetting {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  bool enabled;
  final Color iconColor;
  final Color bgColor;

  NotificationSetting({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.iconColor,
    required this.bgColor,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final RxBool pushEnabled = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxList<NotificationSetting> settings = <NotificationSetting>[].obs;

  @override
  void initState() {
    super.initState();
    settings.assignAll([
      NotificationSetting(
        id: "goals",
        icon: Icons.track_changes,
        title: "Goals & Habits",
        description: "Reminders for daily habits and goal progress",
        enabled: true,
        iconColor: Colors.orange.shade600,
        bgColor: Colors.orange.shade50,
      ),
      NotificationSetting(
        id: "finance",
        icon: Icons.attach_money,
        title: "Finance Alerts",
        description: "Budget warnings and spending notifications",
        enabled: true,
        iconColor: Colors.green.shade600,
        bgColor: Colors.green.shade50,
      ),
      NotificationSetting(
        id: "health",
        icon: Icons.favorite_border,
        title: "Health Reminders",
        description: "Water intake, exercise, and sleep reminders",
        enabled: true,
        iconColor: Colors.red.shade600,
        bgColor: Colors.red.shade50,
      ),
      NotificationSetting(
        id: "wellness",
        icon: Icons.chat_bubble_outline,
        title: "Mental Wellness",
        description: "Mindfulness and journaling prompts",
        enabled: false,
        iconColor: Colors.purple.shade600,
        bgColor: Colors.purple.shade50,
      ),
      NotificationSetting(
        id: "analytics",
        icon: Icons.trending_up,
        title: "Weekly Reports",
        description: "Summary of your weekly progress",
        enabled: true,
        iconColor: Colors.blue.shade600,
        bgColor: Colors.blue.shade50,
      ),
      NotificationSetting(
        id: "email",
        icon: Icons.mail_outline,
        title: "Email Notifications",
        description: "Receive updates via email",
        enabled: false,
        iconColor: Colors.indigo.shade600,
        bgColor: Colors.indigo.shade50,
      ),
    ]);
    _loadFromProfile();
  }

  Future<void> _loadFromProfile() async {
    if (_profileController.profile.value == null) {
      await _profileController.loadProfile();
    }

    final profile = _profileController.profile.value;
    if (profile == null || !mounted) return;

    pushEnabled.value = profile.pushEnabled;
    soundEnabled.value = profile.soundEnabled;

    for (final item in settings) {
      item.enabled = profile.notificationCategories[item.id] ?? item.enabled;
    }
    settings.refresh();
  }

  Future<void> _savePreferences() async {
    final categories = <String, bool>{
      for (final item in settings) item.id: item.enabled,
    };

    try {
      await _profileController.saveNotificationPreferences(
        pushEnabled: pushEnabled.value,
        soundEnabled: soundEnabled.value,
        categories: categories,
      );

      if (!mounted) return;
      Get.snackbar('Success', 'Notification preferences saved.');
      Get.back();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', '$e');
    }
  }

  void _toggleAll(bool value) {
    for (final s in settings) {
      s.enabled = value;
    }
    settings.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () {
        final enabledCount = settings.where((s) => s.enabled).length;

        return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors),
              const SizedBox(height: 24),
              _buildStatusCard(enabledCount, colors),
              const SizedBox(height: 24),
              _buildSectionTitle("GENERAL", colors),
              _buildGeneralSettings(colors),
              const SizedBox(height: 24),
              _buildSectionTitle("CATEGORIES", colors),
              _buildCategoriesList(colors),
              const SizedBox(height: 24),
              _buildQuickActions(colors),
              const SizedBox(height: 16),
              _buildTipCard(colors),
              const SizedBox(height: 24),
              _buildSaveButton(colors),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            Text(
              "Manage your notification preferences",
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(int count, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: colors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications Active",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Text(
                "$count of ${settings.length} categories enabled",
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.onSurface.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: "Push Notifications",
            subtitle: "Receive push notifications on this device",
            value: pushEnabled.value,
            color: colors.primary,
            onChanged: (v) => pushEnabled.value = v,
          ),
          Divider(height: 1, color: colors.outline),
          _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: "Notification Sounds",
            subtitle: "Play sound for notifications",
            value: soundEnabled.value,
            color: colors.secondary,
            onChanged: (v) => soundEnabled.value = v,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface)),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(ColorScheme colors) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = settings[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.bgColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface)),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: item.enabled,
                onChanged: (v) {
                  item.enabled = v;
                  settings.refresh();
                },
                activeColor: colors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _toggleAll(true),
            icon: const Icon(Icons.check, size: 18),
            label: const Text("Enable All"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _toggleAll(false),
            icon: const Icon(Icons.notifications_off_outlined, size: 18),
            label: const Text("Disable All"),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text("💡 "),
          Expanded(
            child: Text(
              "Enable notifications to stay on top of your goals and receive timely reminders throughout the day.",
              style: TextStyle(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: _profileController.isSaving.value ? null : _savePreferences,
          icon: _profileController.isSaving.value
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _profileController.isSaving.value
                ? 'Saving...'
                : 'Save Preferences',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}