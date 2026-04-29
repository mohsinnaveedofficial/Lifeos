import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/goal_entry.dart';

class GoalStorageService {
  GoalStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _goalsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('goals');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use goals sync.');
    }
    return uid;
  }

  Future<List<GoalEntry>> loadGoals() async {
    final uid = _requireUid();

    try {
      final snapshot = await _goalsRef(uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return GoalEntry.fromMap({...data, 'id': data['id'] ?? doc.id});
          })
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<GoalEntry> addGoal({
    required String title,
    required String subtitle,
    required double currentValue,
    required double targetValue,
    required String iconKey,
    required String colorKey,
  }) async {
    final uid = _requireUid();

    try {
      final docRef = _goalsRef(uid).doc();
      final entry = GoalEntry(
        id: docRef.id,
        title: title,
        subtitle: subtitle,
        currentValue: currentValue,
        targetValue: targetValue,
        iconKey: iconKey,
        colorKey: colorKey,
        createdAt: DateTime.now(),
      );

      await docRef.set(entry.toMap());
      return entry;
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final uid = _requireUid();

    try {
      await _goalsRef(uid).doc(goalId).delete();
    } on FirebaseException catch (e) {
      throw StateError('Delete failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

