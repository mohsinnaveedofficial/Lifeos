import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/habit_entry.dart';

class HabitStorageService {
  HabitStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _habitsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('habits');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use habits sync.');
    }
    return uid;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDateKey(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _isYesterday(String lastKey, String todayKey) {
    final last = _parseDateKey(lastKey);
    final today = _parseDateKey(todayKey);
    if (last == null || today == null) return false;
    return today.difference(last).inDays == 1;
  }

  Future<List<HabitEntry>> loadHabits() async {
    final uid = _requireUid();
    final today = _todayKey();

    try {
      final snapshot = await _habitsRef(uid)
          .orderBy('createdAt', descending: true)
          .get();

      final habits = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return HabitEntry.fromMap({...data, 'id': data['id'] ?? doc.id});
          })
          .toList(growable: false);

      for (final habit in habits) {
        if (habit.isCompletedToday && habit.lastCheckDate != today) {
          await _habitsRef(uid).doc(habit.id).set({
            'isCompletedToday': false,
            'lastCheckDate': habit.lastCheckDate,
          }, SetOptions(merge: true));
        }
      }

      return habits
          .map(
            (habit) => habit.lastCheckDate == today
                ? habit
                : habit.copyWith(isCompletedToday: false),
          )
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<HabitEntry> addHabit({
    required String title,
    required String iconKey,
    required String colorKey,
  }) async {
    final uid = _requireUid();

    try {
      final docRef = _habitsRef(uid).doc();
      final entry = HabitEntry(
        id: docRef.id,
        title: title,
        iconKey: iconKey,
        colorKey: colorKey,
        streak: 0,
        isCompletedToday: false,
        lastCheckDate: '',
        createdAt: DateTime.now(),
      );

      await docRef.set(entry.toMap());
      return entry;
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<HabitEntry> updateHabitCompletion({
    required HabitEntry habit,
    required bool completed,
  }) async {
    final uid = _requireUid();
    final today = _todayKey();

    int streak = habit.streak;
    if (completed) {
      if (habit.lastCheckDate == today && habit.isCompletedToday) {
        return habit;
      }
      streak = _isYesterday(habit.lastCheckDate, today) ? streak + 1 : 1;
    } else {
      if (habit.lastCheckDate == today && habit.isCompletedToday && streak > 0) {
        streak -= 1;
      }
    }

    final updated = habit.copyWith(
      isCompletedToday: completed,
      streak: streak,
      lastCheckDate: completed ? today : habit.lastCheckDate,
    );

    try {
      await _habitsRef(uid).doc(habit.id).set({
        'isCompletedToday': updated.isCompletedToday,
        'streak': updated.streak,
        'lastCheckDate': updated.lastCheckDate,
      }, SetOptions(merge: true));

      return updated;
    } on FirebaseException catch (e) {
      throw StateError('Update failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final uid = _requireUid();

    try {
      await _habitsRef(uid).doc(habitId).delete();
    } on FirebaseException catch (e) {
      throw StateError('Delete failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

