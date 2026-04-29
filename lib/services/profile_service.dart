import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lifeos/models/profile_data.dart';

class ProfileService {
  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please login to manage profile data.');
    }
    return user;
  }

  Future<ProfileData> loadProfile() async {
    final user = _requireUser();

    try {
      final snapshot = await _userDoc(user.uid).get();
      final fallbackName = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : '';

      return ProfileData.fromMap(
        snapshot.data(),
        fallbackName: fallbackName,
        fallbackEmail: user.email ?? '',
        fallbackPhotoUrl: user.photoURL ?? '',
      );
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> saveProfile(ProfileData profile) async {
    final user = _requireUser();

    try {
      await _userDoc(user.uid).set({
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(profile.name);

      final currentPhoto = user.photoURL ?? '';
      if (profile.photoUrl.isNotEmpty && profile.photoUrl != currentPhoto) {
        await user.updatePhotoURL(profile.photoUrl);
      }
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String extension,
  }) async {
    final user = _requireUser();
    final safeExtension = extension.isEmpty ? 'jpg' : extension;

    try {
      final ref = _storage
          .ref()
          .child('users/${user.uid}/profile/profile_${DateTime.now().millisecondsSinceEpoch}.$safeExtension');

      await ref.putData(bytes);
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StateError('Upload failed: ${e.code}. Check storage rules/auth.');
    }
  }

  Future<void> saveNotificationPreferences({
    required bool pushEnabled,
    required bool soundEnabled,
    required Map<String, bool> categories,
  }) async {
    final user = _requireUser();

    try {
      await _userDoc(user.uid).set({
        'pushEnabled': pushEnabled,
        'soundEnabled': soundEnabled,
        'notificationCategories': categories,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}



