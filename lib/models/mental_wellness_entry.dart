class MentalWellnessEntry {
  const MentalWellnessEntry({
    required this.dateKey,
    required this.mood,
    required this.journal,
  });

  final String dateKey;
  final String mood;
  final String journal;

  factory MentalWellnessEntry.empty(String dateKey) {
    return MentalWellnessEntry(
      dateKey: dateKey,
      mood: 'Happy',
      journal: '',
    );
  }

  factory MentalWellnessEntry.fromMap(Map<String, dynamic> map) {
    return MentalWellnessEntry(
      dateKey: map['dateKey'] as String? ?? '',
      mood: map['mood'] as String? ?? 'Happy',
      journal: map['journal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'mood': mood,
      'journal': journal,
    };
  }
}

