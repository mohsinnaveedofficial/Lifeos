import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  final RxInt selectedMinutes = 25.obs;
  final RxInt totalSeconds = (25 * 60).obs;
  final RxInt remainingSeconds = (25 * 60).obs;
  final RxBool isRunning = false.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer(selectedMinutes.value);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPauseTimer() {
    if (isRunning.value) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (remainingSeconds.value > 0) {
      isRunning.value = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          _timer?.cancel();
          isRunning.value = false;
        }
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void _resetTimer([int? minutes]) {
    _timer?.cancel();
    if (minutes != null) {
      selectedMinutes.value = minutes;
      totalSeconds.value = minutes * 60;
    }
    remainingSeconds.value = totalSeconds.value;
    isRunning.value = false;
  }

  Future<void> _showCustomTimeDialog() async {
    final theme = Theme.of(context);
    int tempValue = selectedMinutes.value;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Custom Timer',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                color: theme.colorScheme.onSurface, fontSize: 24),
            decoration: InputDecoration(
              hintText: 'Enter minutes',
              hintStyle:
              TextStyle(color: theme.colorScheme.outline),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ADE80)),
              ),
            ),
            onChanged: (val) {
              tempValue = int.tryParse(val) ?? tempValue;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('CANCEL',
                  style: TextStyle(color: theme.colorScheme.outline)),
            ),
            const TextButton(
              onPressed: null,
              child: Text(''),
            ),
            TextButton(
              onPressed: () => Get.back(result: tempValue),
              child: const Text('START',
                  style: TextStyle(color: Color(0xFF4ADE80))),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      _resetTimer(result);
    }
  }

  String get formattedTime {
    final m = remainingSeconds.value ~/ 60;
    final s = remainingSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(
      () {
        final progress = totalSeconds.value == 0
            ? 0.0
            : remainingSeconds.value / totalSeconds.value;

        return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
            ]
                : [
              const Color(0xFF1A397A),
              const Color(0xFF136357),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.chevron_left_rounded,
                        color: theme.colorScheme.onSurface, size: 30),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "CURRENT SESSION",
                          style: TextStyle(
                            color: theme.colorScheme.secondary
                                .withOpacity(0.7),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Deep Focus",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(
                      painter: TimerPainter(
                          progress: progress,
                          theme: theme),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none,
                              color: theme.colorScheme.outline,
                              size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "REMAINING",
                            style: TextStyle(
                              color: theme.colorScheme.outline,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildTimeCard("25", "MINUTES", selectedMinutes.value == 25),
                    const SizedBox(width: 12),
                    _buildTimeCard("45", "MINUTES", selectedMinutes.value == 45),
                    const SizedBox(width: 12),
                    _buildCustomCard(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh,
                          color: theme.colorScheme.onSurface, size: 32),
                      onPressed: () => _resetTimer(),
                    ),
                    GestureDetector(
                      onTap: _startPauseTimer,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4ADE80),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          isRunning.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.black87,
                          size: 40,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.pause,
                          color: theme.colorScheme.onSurface, size: 32),
                      onPressed: isRunning.value ? _pauseTimer : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTimeCard(String value, String label, bool isSelected) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => _resetTimer(int.parse(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.surface.withOpacity(0.3)
                : theme.colorScheme.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: theme.colorScheme.outline)
                : null,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(
                    color: theme.colorScheme.outline, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCard() {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: _showCustomTimeDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.tune,
                  color: theme.colorScheme.onSurface, size: 24),
              Text(
                "CUSTOM",
                style: TextStyle(
                    color: theme.colorScheme.outline, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final ThemeData theme;

  TimerPainter({required this.progress, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const segments = 8;
    const gap = 0.2;
    const sectionLength = (2 * math.pi / segments);

    int activeSegments = (progress * segments).ceil();

    for (int i = 0; i < segments; i++) {
      double startAngle = i * sectionLength - math.pi / 2 + (gap / 2);
      double sweepAngle = sectionLength - gap;

      if (i < activeSegments) {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            activePaint);
      } else {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            bgPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}