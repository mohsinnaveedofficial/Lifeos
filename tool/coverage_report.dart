import 'dart:io';

void main() {
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    print('lcov.info not found. Run: flutter test --coverage');
    exit(2);
  }

  final lines = lcov.readAsLinesSync();
  int total = 0;
  int covered = 0;
  for (final line in lines) {
    if (line.startsWith('LF:')) {
      total += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      covered += int.parse(line.substring(3));
    }
  }

  if (total == 0) {
    print('No lines found in lcov.');
    exit(2);
  }

  final percent = covered / total * 100;
  print('Coverage: ${percent.toStringAsFixed(2)}% ($covered/$total)');

  // exit codes: 0 ok, 1 below threshold
  const threshold = 70.0;
  if (percent < threshold) {
    print('Coverage below threshold ($threshold%).');
    exit(1);
  }
}

