import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lifeos/controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final ProfileController _profileController = Get.find<ProfileController>();

  final RxBool _isSaving = false.obs;
  final RxBool _isUploadingPhoto = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_profileController.profile.value == null) {
      await _profileController.loadProfile();
    }

    final profile = _profileController.profile.value;
    if (profile == null || !mounted) return;

    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _locationController.text = profile.location;
    _dobController.text = profile.dob;
    _bioController.text = profile.bio;
    _photoUrlController.text = profile.photoUrl;
  }

  Future<void> _handleSave() async {
    final current = _profileController.profile.value;
    if (current == null) {
      Get.snackbar('Error', 'Unable to load profile data.');
      return;
    }

    _isSaving.value = true;

    try {
      final updated = current.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        dob: _dobController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: _photoUrlController.text.trim(),
      );

      await _profileController.saveProfileData(updated);

      if (!mounted) return;
      _isSaving.value = false;
      Get.snackbar('Success', 'Profile updated successfully.');
      Get.back();
    } catch (e) {
      if (!mounted) return;
      _isSaving.value = false;
      Get.snackbar('Error', '$e');
    }
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = colorScheme.primary;
    final Color mutedColor = isDark
        ? colorScheme.surface
        : Colors.grey.shade100;
    final Color borderColor = isDark
        ? colorScheme.outline
        : Colors.grey.shade300;

    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 96,
            ),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Update your personal information',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0,
                child: Column(
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _nameController,
                          _photoUrlController,
                        ]),
                        builder: (context, _) {
                          final hasPhoto = _photoUrlController.text.trim().isNotEmpty;
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? colorScheme.surface
                                        : Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                   radius: 56,
                                   backgroundColor: mutedColor,
                                   backgroundImage: hasPhoto
                                       ? CachedNetworkImageProvider(
                                           _photoUrlController.text.trim(),
                                         )
                                       : null,
                                   onBackgroundImageError: hasPhoto
                                       ? (_, __) {}
                                       : null,
                                   child: hasPhoto
                                       ? null
                                       : Text(
                                           _initials(_nameController.text),
                                           style: TextStyle(
                                             fontSize: 24,
                                             color: colorScheme.onSurface,
                                           ),
                                         ),
                                 ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? colorScheme.surface
                                        : Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed:
                          _isUploadingPhoto.value ? null : _pickAndUploadPhoto,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: borderColor),
                      ),
                      child: _isUploadingPhoto.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Change Photo',
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0.1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black54
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        controller: _nameController,
                        hint: 'Enter your full name',
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Email Address',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        hint: 'your.email@example.com',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        hint: '+1 (555) 000-0000',
                        keyboardType: TextInputType.phone,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        controller: _locationController,
                        hint: 'City, State/Country',
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Date of Birth',
                        icon: Icons.calendar_today_outlined,
                        controller: _dobController,
                        hint: 'YYYY-MM-DD',
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Bio',
                        icon: Icons.info_outline,
                        controller: _bioController,
                        hint: 'Tell us about yourself...',
                        maxLines: 4,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        primaryColor: primaryColor,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: 0.2,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving.value ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Save Changes'),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: borderColor),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required Color mutedColor,
    required Color borderColor,
    required Color primaryColor,
    required BuildContext context,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: mutedColor,
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
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (picked == null) return;

    try {
      _isUploadingPhoto.value = true;
      final url = await _profileController.uploadPhotoFromPicker(picked);
      if (!mounted) return;
      _photoUrlController.text = url;
      _isUploadingPhoto.value = false;
    } catch (e) {
      if (!mounted) return;
      _isUploadingPhoto.value = false;
      Get.snackbar('Error', '$e');
    }
  }
}

class FadeSlideTransition extends StatelessWidget {
  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.delay,
  });

  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, childWidget) {
        final adjustedValue =
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
