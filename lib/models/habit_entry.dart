class HabitEntry {
  const HabitEntry({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.colorKey,
    required this.streak,
    required this.isCompletedToday,
    required this.lastCheckDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String iconKey;
  final String colorKey;
  final int streak;
  final bool isCompletedToday;
  final String lastCheckDate;
  final DateTime createdAt;

  HabitEntry copyWith({
    String? id,
    String? title,
    String? iconKey,
    String? colorKey,
    int? streak,
    bool? isCompletedToday,
    String? lastCheckDate,
    DateTime? createdAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      streak: streak ?? this.streak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCheckDate: lastCheckDate ?? this.lastCheckDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? 'habit',
      colorKey: map['colorKey'] as String? ?? 'blue',
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      isCompletedToday: map['isCompletedToday'] as bool? ?? false,
      lastCheckDate: map['lastCheckDate'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconKey': iconKey,
      'colorKey': colorKey,
      'streak': streak,
      'isCompletedToday': isCompletedToday,
      'lastCheckDate': lastCheckDate,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

