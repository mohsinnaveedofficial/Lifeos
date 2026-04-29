class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date,
      'isIncome': isIncome,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory FinanceEntry.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;

    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FinanceEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: parsedDate,
      isIncome: map['isIncome'] as bool? ?? false,
    );
  }

  factory FinanceEntry.fromJson(Map<String, dynamic> json) => FinanceEntry.fromMap(json);
}
