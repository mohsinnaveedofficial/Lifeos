class PasswordStrength {
  final bool length;
  final bool uppercase;
  final bool lowercase;
  final bool number;
  final bool special;

  PasswordStrength({
    required this.length,
    required this.uppercase,
    required this.lowercase,
    required this.number,
    required this.special,
  });

  bool get isValid => length && uppercase && lowercase && number && special;
}

PasswordStrength checkPasswordStrength(String value) {
  return PasswordStrength(
    length: value.length >= 8,
    uppercase: RegExp(r'[A-Z]').hasMatch(value),
    lowercase: RegExp(r'[a-z]').hasMatch(value),
    number: RegExp(r'[0-9]').hasMatch(value),
    special: RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(value),
  );
}

String initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'U';
  final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) {
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}

int moodToScore(String mood) {
  switch (mood) {
    case 'Stressed':
      return 1;
    case 'Neutral':
      return 2;
    case 'Happy':
      return 3;
    case 'Excited':
      return 4;
    case 'Loved':
      return 5;
    default:
      return 3;
  }
}

String lastCheckInLabel(String dateKey) {
  final parts = dateKey.split('-');
  if (parts.length != 3) return dateKey;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return dateKey;
  final checkInDate = DateTime(year, month, day);
  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final normalizedCheckIn = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
  final diffDays = normalizedToday.difference(normalizedCheckIn).inDays;
  if (diffDays <= 0) return 'Today';
  if (diffDays == 1) return 'Yesterday';
  return '$diffDays days ago';
}

String formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

