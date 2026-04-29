import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StepCounterService {
  static const String _baselineDateKey = 'step_baseline_date';
  static const String _baselineValueKey = 'step_baseline_value';
  static const String _lastSyncKey = 'step_last_sync';

  final StreamController<int> _todayStepsController =
      StreamController<int>.broadcast();
  StreamSubscription<StepCount>? _stepsSubscription;
  DateTime? _lastSync;

  Stream<int> get todayStepsStream => _todayStepsController.stream;

  // Initialize and start monitoring on service creation
  StepCounterService() {
    _initializeStepTracking();
  }

  Future<void> _initializeStepTracking() async {
    // Load last sync time to restore state across app restarts
    await _loadLastSync();
    // Start listening to steps immediately
    await start();
  }

  Future<void> _loadLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      if (lastSyncStr != null) {
        _lastSync = DateTime.parse(lastSyncStr);
      }
    } catch (e) {
      if (kDebugMode) print('Error loading last sync: $e');
    }
  }

  Future<void> _saveLastSync(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, time.toIso8601String());
      _lastSync = time;
    } catch (e) {
      if (kDebugMode) print('Error saving last sync: $e');
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<void> start() async {
    await stop();
    // Request permission automatically if not granted
    final permGranted = await requestPermission();
    if (!permGranted) {
      _todayStepsController.addError('Activity recognition permission denied');
      return;
    }

    _stepsSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (Object error) {
        _todayStepsController.addError(error);
      },
      cancelOnError: false,
    );

    // Save current time as sync point
    await _saveLastSync(DateTime.now());
  }

  Future<void> stop() async {
    await _stepsSubscription?.cancel();
    _stepsSubscription = null;
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final savedDate = prefs.getString(_baselineDateKey);
    int baseline = prefs.getInt(_baselineValueKey) ?? event.steps;

    // If date changed, reset baseline (new day)
    if (savedDate != dateKey) {
      baseline = event.steps;
      await prefs.setString(_baselineDateKey, dateKey);
      await prefs.setInt(_baselineValueKey, baseline);
    }

    final stepsToday = (event.steps - baseline).clamp(0, 1000000);
    _todayStepsController.add(stepsToday);

    // Update sync time to track last update
    await _saveLastSync(DateTime.now());
  }

  Future<void> dispose() async {
    await stop();
    await _todayStepsController.close();
  }
}

