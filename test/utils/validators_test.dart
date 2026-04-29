import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/utils/validators.dart';

void main() {
  group('PasswordStrength', () {
    test('valid strong password', () {
      final strength = checkPasswordStrength('Abcdef1!');
      expect(strength.length, isTrue);
      expect(strength.uppercase, isTrue);
      expect(strength.lowercase, isTrue);
      expect(strength.number, isTrue);
      expect(strength.special, isTrue);
      expect(strength.isValid, isTrue);
    });

    test('invalid weak password', () {
      final strength = checkPasswordStrength('abc');
      expect(strength.length, isFalse);
      expect(strength.isValid, isFalse);
    });
  });

  group('Initials', () {
    test('single name', () {
      expect(initials('Alice'), 'AL');
    });

    test('two names', () {
      expect(initials('John Doe'), 'JD');
    });

    test('empty', () {
      expect(initials('   '), 'U');
    });
  });

  group('Mood to Score', () {
    test('known moods', () {
      expect(moodToScore('Stressed'), 1);
      expect(moodToScore('Neutral'), 2);
      expect(moodToScore('Happy'), 3);
      expect(moodToScore('Excited'), 4);
      expect(moodToScore('Loved'), 5);
    });

    test('unknown mood', () {
      expect(moodToScore('Bored'), 3);
    });
  });

  group('Last Check In Label', () {
    test('today', () {
      final today = DateTime.now();
      final key = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      expect(lastCheckInLabel(key), 'Today');
    });

    test('yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days:1));
      final key = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
      expect(lastCheckInLabel(key), 'Yesterday');
    });

    test('days ago', () {
      final daysAgo = DateTime.now().subtract(const Duration(days:5));
      final key = '${daysAgo.year}-${daysAgo.month.toString().padLeft(2,'0')}-${daysAgo.day.toString().padLeft(2,'0')}';
      expect(lastCheckInLabel(key).contains('days ago'), isTrue);
    });
  });

  group('Format currency', () {
    test('format', () {
      expect(formatCurrency(12.5), '\$12.50');
    });
  });
}

