class GoalEntry {
  const GoalEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.targetValue,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final double currentValue;
  final double targetValue;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;

  factory GoalEntry.fromMap(Map<String, dynamic> map) {
    return GoalEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      currentValue: (map['currentValue'] as num?)?.toDouble() ?? 0,
      targetValue: (map['targetValue'] as num?)?.toDouble() ?? 1,
      iconKey: map['iconKey'] as String? ?? 'goal',
      colorKey: map['colorKey'] as String? ?? 'blue',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'iconKey': iconKey,
      'colorKey': colorKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

