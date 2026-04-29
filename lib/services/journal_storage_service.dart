import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/journal_entry.dart';

class JournalStorageService {
  JournalStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _entriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('journal_entries');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use journal sync.');
    }
    return uid;
  }

  Stream<List<JournalEntry>> watchEntries({int limit = 25}) {
    final uid = _requireUid();
    return _entriesRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntry.fromDoc(doc))
            .toList(growable: false));
  }

  Future<void> createEntry({
    required String moodEmoji,
    required String moodLabel,
    required List<String> gratefulList,
    required String reflection,
  }) async {
    final uid = _requireUid();

    try {
      await _entriesRef(uid).add(<String, dynamic>{
        'moodEmoji': moodEmoji,
        'moodLabel': moodLabel,
        'gratefulList': gratefulList,
        'reflection': reflection,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw StateError('Save failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    final uid = _requireUid();

    try {
      await _entriesRef(uid).doc(entryId).delete();
    } on FirebaseException catch (e) {
      throw StateError('Delete failed: ${e.code}. Check Firestore rules/auth.');
    }
  }
}

