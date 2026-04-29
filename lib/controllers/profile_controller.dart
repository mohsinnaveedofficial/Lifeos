import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifeos/models/profile_data.dart';
import 'package:lifeos/services/profile_service.dart';
import 'package:lifeos/services/secure_storage_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._profileService, this._secureStorageService);

  final ProfileService _profileService;
  final SecureStorageService _secureStorageService;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<ProfileData> profile = Rxn<ProfileData>();

  static const String onboardingNameKey = 'onboarding_name';
  static const String onboardingFocusAreasKey = 'onboarding_focus_areas';

  Future<void> loadProfile() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      profile.value = await _profileService.loadProfile();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfileData(ProfileData updatedProfile) async {
    try {
      isSaving.value = true;
      await _profileService.saveProfile(updatedProfile);
      profile.value = updatedProfile;
    } finally {
      isSaving.value = false;
    }
  }

  Future<String> uploadPhotoFromPicker(XFile pickedFile) async {
    final ext = pickedFile.path.split('.').last.toLowerCase();
    final bytes = await pickedFile.readAsBytes();
    return _profileService.uploadProfilePhoto(
      bytes: Uint8List.fromList(bytes),
      extension: ext,
    );
  }

  Future<void> saveOnboardingDraft({
    required String name,
    required List<String> focusAreas,
  }) async {
    await _secureStorageService.writeString(onboardingNameKey, name);
    await _secureStorageService.writeStringList(
      onboardingFocusAreasKey,
      focusAreas,
    );
  }

  Future<Map<String, dynamic>> readOnboardingDraft() async {
    final savedName = await _secureStorageService.readString(onboardingNameKey);
    final savedFocus = await _secureStorageService.readStringList(
      onboardingFocusAreasKey,
    );

    return <String, dynamic>{
      'name': savedName ?? '',
      'focusAreas': savedFocus,
    };
  }

  Future<void> syncOnboardingDraftIfAny() async {
    final draftName =
        (await _secureStorageService.readString(onboardingNameKey) ?? '').trim();
    final draftFocus = await _secureStorageService.readStringList(
      onboardingFocusAreasKey,
    );

    if (draftName.isEmpty && draftFocus.isEmpty) return;

    await loadProfile();
    final current = profile.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: draftName.isNotEmpty ? draftName : current.name,
      focusAreas: draftFocus.isNotEmpty ? draftFocus : current.focusAreas,
    );

    await saveProfileData(updated);
    await _secureStorageService.delete(onboardingNameKey);
    await _secureStorageService.delete(onboardingFocusAreasKey);
  }

  Future<void> saveNotificationPreferences({
    required bool pushEnabled,
    required bool soundEnabled,
    required Map<String, bool> categories,
  }) async {
    try {
      isSaving.value = true;
      await _profileService.saveNotificationPreferences(
        pushEnabled: pushEnabled,
        soundEnabled: soundEnabled,
        categories: categories,
      );

      final current = profile.value;
      if (current != null) {
        profile.value = current.copyWith(
          pushEnabled: pushEnabled,
          soundEnabled: soundEnabled,
          notificationCategories: categories,
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}



