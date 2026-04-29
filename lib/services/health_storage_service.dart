import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/health_daily_entry.dart';

class HealthStorageService {
  HealthStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _dailyRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('health_daily');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use health sync.');
    }
    return uid;
  }

  Future<HealthDailyEntry> loadDailyEntry(String dateKey) async {
    final uid = _requireUid();

    try {
      final snapshot = await _dailyRef(uid).doc(dateKey).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return HealthDailyEntry.empty(dateKey);
      }

      return HealthDailyEntry.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> saveDailyEntry(HealthDailyEntry entry) async {
    final uid = _requireUid();

    try {
      await _dailyRef(uid).doc(entry.dateKey).set({
        ...entry.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<List<HealthDailyEntry>> loadHistory({int limit = 30}) async {
    final uid = _requireUid();

    try {
      final snapshot = await _dailyRef(uid)
          .orderBy('dateKey', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => HealthDailyEntry.fromMap(doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

