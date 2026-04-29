import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifeos/models/health_daily_entry.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/health_storage_service.dart';
import 'package:lifeos/services/step_counter_service.dart';

class Health extends StatefulWidget {
  const Health({super.key});

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> with WidgetsBindingObserver {
  static const int _stepGoal = 10000;
  static const int _waterGoal = 2500;
  static const int _sleepGoalMinutes = 8 * 60;

  final HealthStorageService _healthStorageService = HealthStorageService();
  final StepCounterService _stepCounterService = StepCounterService();

  StreamSubscription<int>? _stepSubscription;

  int _steps = 0;
  int _waterMl = 0;
  int _sleepMinutes = 0;
  int _healthScore = 0;
  bool _isLoading = true;
  String? _error;
  int _lastSyncedSteps = 0;
  String _activeDateKey = '';
  Timer? _dayWatcherTimer;
  final RxInt _stateTick = 0.obs;

  void _refresh() {
    _stateTick.value++;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeDateKey = _todayKey();
    _initHealth();
    _startDayWatcher();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayWatcherTimer?.cancel();
    _stepSubscription?.cancel();
    _stepCounterService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForNewDayAndReset();
    }
  }

  void _startDayWatcher() {
    _dayWatcherTimer?.cancel();
    _dayWatcherTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) => _checkForNewDayAndReset(),
    );
  }

  Future<void> _checkForNewDayAndReset() async {
    final today = _todayKey();
    if (today == _activeDateKey) return;

    if (!mounted) return;
    _activeDateKey = today;
    _isLoading = true;
    _error = null;
    _steps = 0;
    _waterMl = 0;
    _sleepMinutes = 0;
    _healthScore = 0;
    _lastSyncedSteps = 0;
    _refresh();

    await _loadTodayHealth();
  }

  Future<void> _initHealth() async {
    await _loadTodayHealth();
    await _startStepTracking();
  }

  Future<void> _loadTodayHealth() async {
    try {
      final today = _todayKey();
      final entry = await _healthStorageService.loadDailyEntry(today);
      if (!mounted) return;

      _activeDateKey = today;
      _steps = entry.steps;
      _waterMl = entry.waterMl;
      _sleepMinutes = entry.sleepMinutes;
      _healthScore = entry.healthScore;
      _lastSyncedSteps = entry.steps;
      _isLoading = false;
      _error = null;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _isLoading = false;
      _error = '$e';
      _refresh();
    }
  }

  Future<void> _startStepTracking() async {
    final granted = await _stepCounterService.requestPermission();
    if (!granted) {
      if (!mounted) return;
      Get.snackbar(
        'Permission needed',
        'Allow activity permission to auto-track steps.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _stepCounterService.start();

    _stepSubscription = _stepCounterService.todayStepsStream.listen(
          (stepsToday) async {
        if (!mounted) return;

        final mergedSteps = stepsToday > _steps ? stepsToday : _steps;
        if (mergedSteps == _steps) return;

        _steps = mergedSteps;
        _healthScore = _calculateHealthScore(
          steps: _steps,
          waterMl: _waterMl,
          sleepMinutes: _sleepMinutes,
        );
        _refresh();

        final shouldSync = (_steps - _lastSyncedSteps).abs() >= 20;
        if (shouldSync) {
          _lastSyncedSteps = _steps;
          await _saveCurrentHealth();
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        Get.snackbar(
          'Step tracking error',
          '$error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  int _calculateHealthScore({
    required int steps,
    required int waterMl,
    required int sleepMinutes,
  }) {
    final stepPart = ((steps / _stepGoal) * 50).clamp(0, 50).round();
    final waterPart = ((waterMl / _waterGoal) * 20).clamp(0, 20).round();
    final sleepPart = ((sleepMinutes / _sleepGoalMinutes) * 30)
        .clamp(0, 30)
        .round();
    return (stepPart + waterPart + sleepPart).clamp(0, 100);
  }

  Future<void> _saveCurrentHealth() async {
    final entry = HealthDailyEntry(
      dateKey: _todayKey(),
      steps: _steps,
      waterMl: _waterMl,
      sleepMinutes: _sleepMinutes,
      healthScore: _healthScore,
    );

    try {
      await _healthStorageService.saveDailyEntry(entry);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Sync failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day
        .toString().padLeft(2, '0')}';
  }

  String _todayLabel() {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return 'Today, ${months[now.month - 1]} ${now.day}';
  }

  String _formatSteps(int value) {
    final text = value.toString();
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
  }

  String _sleepLabel(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}m / 8h';
  }

  String _statusLabel() {
    if (_healthScore >= 80) return 'Excellent!';
    if (_healthScore >= 60) return 'Good job!';
    if (_healthScore >= 40) return 'Keep going!';
    return 'Let\'s improve!';
  }

  String _statusSubtitle() {
    if (_healthScore >= 80) return 'You are doing great today. Keep it up!';
    if (_healthScore >= 60) return 'Nice progress. A bit more activity helps.';
    if (_healthScore >= 40) return 'Try completing your water and sleep goals.';
    return 'Take a walk, drink water, and rest well.';
  }

  Future<void> _addWater(int ml) async {
    _waterMl += ml;
    _healthScore = _calculateHealthScore(
      steps: _steps,
      waterMl: _waterMl,
      sleepMinutes: _sleepMinutes,
    );
    _refresh();
    await _saveCurrentHealth();
  }

  Future<void> _saveSleep(TimeOfDay bedTime, TimeOfDay wakeTime) async {
    final bedMinutes = bedTime.hour * 60 + bedTime.minute;
    var wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;

    if (wakeMinutes <= bedMinutes) {
      wakeMinutes += 24 * 60;
    }

    final totalSleep = wakeMinutes - bedMinutes;

    _sleepMinutes = totalSleep;
    _healthScore = _calculateHealthScore(
      steps: _steps,
      waterMl: _waterMl,
      sleepMinutes: _sleepMinutes,
    );
    _refresh();
    await _saveCurrentHealth();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(
            () {
          _stateTick.value;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              Get.offAllNamed(AppRoutes.home);
            },
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _isLoading = true;
                            _error = null;
                            _refresh();
                            _initHealth();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Health',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _todayLabel(),
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        padding:
                        const EdgeInsets.symmetric(vertical: 25),
                        decoration: BoxDecoration(
                          color: const Color(0xffF7E6E6),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withValues(alpha: .08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 160,
                              width: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 160,
                                    width: 160,
                                    child: CircularProgressIndicator(
                                      value: (_healthScore / 100)
                                          .clamp(0, 1),
                                      strokeWidth: 12,
                                      backgroundColor:
                                      colorScheme.surface,
                                      color: Colors.red,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.monitor_heart,
                                        color: Colors.red,
                                        size: 26,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '$_healthScore',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _statusLabel(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _statusSubtitle(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Activity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.healthAnalytics),
                            child: const Text('View History'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      activityCard(
                        context: context,
                        icon: Icons.directions_walk,
                        title: 'Steps',
                        progress: (_steps / _stepGoal).clamp(0, 1),
                        value:
                        '${_formatSteps(_steps)} / ${_formatSteps(_stepGoal)}',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      activityCard(
                        context: context,
                        icon: Icons.water_drop,
                        title: 'Water',
                        progress: (_waterMl / _waterGoal).clamp(0, 1),
                        value: '$_waterMl / $_waterGoal ml',
                        color: Colors.blue,
                        button: true,
                        btnicon: Icons.add,
                        onTap: showWaterDialog,
                      ),
                      const SizedBox(height: 16),
                      activityCard(
                        context: context,
                        icon: Icons.nightlight_round,
                        title: 'Sleep',
                        progress: (_sleepMinutes / _sleepGoalMinutes)
                            .clamp(0, 1),
                        value: _sleepLabel(_sleepMinutes),
                        color: Colors.purple,
                        button: true,
                        greenButton: true,
                        btnicon: Icons.access_time_rounded,
                        onTap: showSleepDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget activityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required double progress,
    required Color color,
    IconData? btnicon,
    VoidCallback? onTap,
    bool button = false,
    bool greenButton = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(20),
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: .15),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
              if (button)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: greenButton ? Colors.green : colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton.icon(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(20, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      btnicon,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void showSleepDialog() {
    TimeOfDay bedTime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 30);

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme
            .of(context)
            .colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Sleep Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When did you sleep?',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Bedtime',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    timeField(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                          bedTime),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: bedTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            bedTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wake Time',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    timeField(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                          wakeTime),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: wakeTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            wakeTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              colorScheme.outline.withValues(alpha: 0.2),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              await _saveSleep(bedTime, wakeTime);
                              if (!mounted) return;
                              Get.back();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget timeField(String time, {required VoidCallback onTap}) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Icon(Icons.access_time, size: 18, color: colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  void showWaterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme
            .of(context)
            .colorScheme;
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Water Intake',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How much water did you drink?',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    waterButton('+ 250ml', () async {
                      await _addWater(250);
                      if (!mounted) return;
                      Get.back();
                    }),
                    const SizedBox(width: 12),
                    waterButton('+ 500ml', () async {
                      await _addWater(500);
                      if (!mounted) return;
                      Get.back();
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    waterButton('+ 750ml', () async {
                      await _addWater(750);
                      if (!mounted) return;
                      Get.back();
                    }),
                    const SizedBox(width: 12),
                    waterButton('+ 1000ml', () async {
                      await _addWater(1000);
                      if (!mounted) return;
                      Get.back();
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.outline.withValues(
                          alpha: 0.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget waterButton(String text, Future<void> Function() onTap) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
