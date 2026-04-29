import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifeos/models/finance_entry.dart';

class FinanceStorageService {
  FinanceStorageService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _entriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('finance_entries');
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Please login to use finance data sync.');
    }
    return uid;
  }

  Future<List<FinanceEntry>> loadEntries() async {
    final uid = _requireUid();

    try {
      final snapshot = await _entriesRef(uid).get();

      final entries = snapshot.docs.map((doc) {
        final data = doc.data();
        final rawDate = data['date'];
        final normalized = <String, dynamic>{
          ...data,
          'id': data['id'] ?? doc.id,
          'date': rawDate is Timestamp ? rawDate.toDate() : rawDate,
        };
        return FinanceEntry.fromMap(normalized);
      }).toList();

      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } on FirebaseException catch (e) {
      throw StateError('Load failed: ${e.code}. Check Firestore rules/auth.');
    }
  }

  Future<void> addEntry(FinanceEntry entry) async {
    final uid = _requireUid();

    try {
      await _entriesRef(uid).doc(entry.id).set({
        ...entry.toMap(),
        'date': Timestamp.fromDate(entry.date),
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
