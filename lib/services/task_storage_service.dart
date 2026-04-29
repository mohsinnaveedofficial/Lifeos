import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskStorageService {
  TaskStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use task sync.');
    }
    return uid;
  }

  Future<List<Map<String, dynamic>>> loadTasks() async {
    final uid = _requireUid();

    try {
      final snapshot = await _tasksRef(uid)
          .orderBy('deadline', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawDeadline = data['deadline'];
        return <String, dynamic>{
          ...data,
          'id': doc.id,
          'deadline': rawDeadline is Timestamp
              ? rawDeadline.toDate()
              : DateTime.tryParse('$rawDeadline') ?? DateTime.now(),
          'title': data['title'] ?? '',
          'category': data['category'] ?? 'General',
          'priority': data['priority'] ?? 'Medium',
          'completed': data['completed'] == true,
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required DateTime deadline,
    required String category,
    required String priority,
  }) async {
    final uid = _requireUid();

    try {
      final docRef = _tasksRef(uid).doc();
      final taskData = <String, dynamic>{
        'title': title,
        'deadline': Timestamp.fromDate(deadline),
        'category': category,
        'priority': priority,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(taskData);

      return <String, dynamic>{
        'id': docRef.id,
        'title': title,
        'deadline': deadline,
        'category': category,
        'priority': priority,
        'completed': false,
      };
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> updateTaskCompletion({
    required String taskId,
    required bool completed,
  }) async {
    final uid = _requireUid();

    try {
      await _tasksRef(uid).doc(taskId).update({'completed': completed});
    } on FirebaseException catch (e) {
      throw StateError('Update failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final uid = _requireUid();

    try {
      await _tasksRef(uid).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw StateError('Delete failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

