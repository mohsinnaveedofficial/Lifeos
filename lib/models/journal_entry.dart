import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.moodEmoji,
    required this.moodLabel,
    required this.gratefulList,
    required this.reflection,
    required this.createdAt,
  });

  final String id;
  final String moodEmoji;
  final String moodLabel;
  final List<String> gratefulList;
  final String reflection;
  final DateTime createdAt;

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawCreatedAt = data['createdAt'];

    return JournalEntry(
      id: doc.id,
      moodEmoji: data['moodEmoji'] as String? ?? '🙂',
      moodLabel: data['moodLabel'] as String? ?? 'Okay',
      gratefulList: (data['gratefulList'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      reflection: data['reflection'] as String? ?? '',
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : DateTime.tryParse('$rawCreatedAt') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'moodEmoji': moodEmoji,
      'moodLabel': moodLabel,
      'gratefulList': gratefulList,
      'reflection': reflection,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

