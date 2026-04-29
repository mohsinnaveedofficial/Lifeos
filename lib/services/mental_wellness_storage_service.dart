import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/mental_wellness_entry.dart';

class MentalWellnessStorageService {
  MentalWellnessStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _entriesRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('mental_wellness_daily');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use mental wellness sync.');
    }
    return uid;
  }

  Future<MentalWellnessEntry> loadDailyEntry(String dateKey) async {
    final uid = _requireUid();

    try {
      final snapshot = await _entriesRef(uid).doc(dateKey).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return MentalWellnessEntry.empty(dateKey);
      }

      return MentalWellnessEntry.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> saveDailyEntry(MentalWellnessEntry entry) async {
    final uid = _requireUid();

    try {
      await _entriesRef(uid).doc(entry.dateKey).set({
        ...entry.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<List<MentalWellnessEntry>> loadHistory({int limit = 30}) async {
    final uid = _requireUid();

    try {
      final snapshot = await _entriesRef(uid)
          .orderBy('dateKey', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => MentalWellnessEntry.fromMap(doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> deleteDailyEntry(String dateKey) async {
    final uid = _requireUid();

    try {
      await _entriesRef(uid).doc(dateKey).delete();
    } on FirebaseException catch (e) {
      throw StateError('Delete failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

