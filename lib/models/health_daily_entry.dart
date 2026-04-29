class HealthDailyEntry {
  const HealthDailyEntry({
    required this.dateKey,
    required this.steps,
    required this.waterMl,
    required this.sleepMinutes,
    required this.healthScore,
  });

  final String dateKey;
  final int steps;
  final int waterMl;
  final int sleepMinutes;
  final int healthScore;

  factory HealthDailyEntry.empty(String dateKey) {
    return HealthDailyEntry(
      dateKey: dateKey,
      steps: 0,
      waterMl: 0,
      sleepMinutes: 0,
      healthScore: 0,
    );
  }

  factory HealthDailyEntry.fromMap(Map<String, dynamic> map) {
    return HealthDailyEntry(
      dateKey: map['dateKey'] as String? ?? '',
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      waterMl: (map['waterMl'] as num?)?.toInt() ?? 0,
      sleepMinutes: (map['sleepMinutes'] as num?)?.toInt() ?? 0,
      healthScore: (map['healthScore'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'steps': steps,
      'waterMl': waterMl,
      'sleepMinutes': sleepMinutes,
      'healthScore': healthScore,
    };
  }

  HealthDailyEntry copyWith({
    int? steps,
    int? waterMl,
    int? sleepMinutes,
    int? healthScore,
  }) {
    return HealthDailyEntry(
      dateKey: dateKey,
      steps: steps ?? this.steps,
      waterMl: waterMl ?? this.waterMl,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      healthScore: healthScore ?? this.healthScore,
    );
  }
}

