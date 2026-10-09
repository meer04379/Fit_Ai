import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepTrackerService {
  static final StepTrackerService _instance = StepTrackerService._internal();
  factory StepTrackerService() => _instance;
  StepTrackerService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  void Function(int todaySteps)? onStepCountChanged;
  void Function(String status)? onPedestrianStatusChanged;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int? _cachedBaseline;
  int _lastRawSteps = 0;
  int get lastRawSteps => _lastRawSteps;
  int _currentTodaySteps = 0;
  int get currentTodaySteps => _currentTodaySteps;

  bool _resetPending = false;
  String _currentDayKey = '';

  /// Initialize step tracking safely
  Future<void> init({
    void Function(int todaySteps)? onSteps,
    void Function(String status)? onStatus,
  }) async {
    if (onSteps != null) onStepCountChanged = onSteps;
    if (onStatus != null) onPedestrianStatusChanged = onStatus;

    _updateDayKey();
    await _loadBaselineFromStorage();

    if (_isInitialized) return;

    // Pedometer sensors are only available on physical Android / iOS devices
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[StepTracker] Pedometer not supported on this platform (Web/Desktop).');
      return;
    }

    try {
      // 1. Request Permission on Mobile
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        debugPrint('[StepTracker] Activity recognition permission not granted: $status');
        return;
      }

      // 2. Initialize Streams
      _initStepCountStream();
      _initPedestrianStatusStream();
      _isInitialized = true;
      debugPrint('[StepTracker] Auto Step Tracking initialized successfully.');
    } catch (e) {
      debugPrint('[StepTracker] Failed to initialize pedometer: $e');
    }
  }

  void _updateDayKey() {
    final now = DateTime.now();
    _currentDayKey = 'steps_baseline_${now.year}_${now.month}_${now.day}';
  }

  Future<void> _loadBaselineFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedBaseline = prefs.getInt(_currentDayKey);
      debugPrint('[StepTracker] Loaded baseline from storage: $_cachedBaseline for key $_currentDayKey');
    } catch (e) {
      debugPrint('[StepTracker] Error loading baseline: $e');
    }
  }

  void _initStepCountStream() {
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[StepTracker] Error starting step count stream: $e');
    }
  }

  void _initPedestrianStatusStream() {
    try {
      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[StepTracker] Error starting pedestrian status stream: $e');
    }
  }

  /// Resets today's baseline to the current raw steps so user count starts at [targetSteps] (default 0)
  Future<void> resetBaseline([int targetSteps = 0]) async {
    _updateDayKey();
    if (_lastRawSteps > 0) {
      _cachedBaseline = _lastRawSteps - targetSteps;
      _currentTodaySteps = targetSteps;
      _resetPending = false;
      _persistBaseline(_cachedBaseline!);
      debugPrint('[StepTracker] Baseline reset to: $_cachedBaseline (Target: $targetSteps)');
    } else {
      // Hardware sensor hasn't delivered a reading yet.
      // Mark as pending so the very next sensor tick establishes baseline.
      _resetPending = true;
      _cachedBaseline = null;
      _currentTodaySteps = targetSteps;
      _removeBaseline();
      debugPrint('[StepTracker] Sensor not yet reported. Reset marked as pending.');
    }
    onStepCountChanged?.call(targetSteps);
  }

  void _persistBaseline(int baseline) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_currentDayKey, baseline);
    }).catchError((e) {
      debugPrint('[StepTracker] Persist baseline error: $e');
    });
  }

  void _removeBaseline() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_currentDayKey);
    }).catchError((e) {
      debugPrint('[StepTracker] Remove baseline error: $e');
    });
  }

  Future<void> _onStepCount(StepCount event) async {
    _lastRawSteps = event.steps;
    final rawSteps = event.steps;
    _updateDayKey();

    try {
      // 1. If a reset was requested before the sensor started, lock in baseline now
      if (_resetPending) {
        _resetPending = false;
        _cachedBaseline = rawSteps;
        _persistBaseline(_cachedBaseline!);
        _currentTodaySteps = 0;
        debugPrint('[StepTracker] Pending reset resolved. New baseline: $_cachedBaseline');
        onStepCountChanged?.call(0);
        return;
      }

      // 2. If no baseline in memory, check storage or set current rawSteps as baseline
      if (_cachedBaseline == null) {
        final prefs = await SharedPreferences.getInstance();
        _cachedBaseline = prefs.getInt(_currentDayKey);

        if (_cachedBaseline == null) {
          // First reading today, establish baseline at current sensor count
          _cachedBaseline = rawSteps;
          await prefs.setInt(_currentDayKey, rawSteps);
          debugPrint('[StepTracker] Initialized day baseline at: $rawSteps');
        }
      }

      // 3. Device reboot check: if rawSteps is lower than baseline, device was restarted
      if (rawSteps < _cachedBaseline!) {
        debugPrint('[StepTracker] Device reboot detected. Adjusting baseline to $rawSteps');
        _cachedBaseline = rawSteps;
        _persistBaseline(rawSteps);
      }

      // 4. Calculate clean steps for today
      final calculatedSteps = (rawSteps - _cachedBaseline!).clamp(0, 1000000);
      _currentTodaySteps = calculatedSteps;
      debugPrint('[StepTracker] Live Steps: $calculatedSteps (Raw: $rawSteps, Baseline: $_cachedBaseline)');
      onStepCountChanged?.call(calculatedSteps);
    } catch (e) {
      debugPrint('[StepTracker] Error calculating steps: $e');
      // NEVER leak rawSteps on error; retain current valid steps
      onStepCountChanged?.call(_currentTodaySteps);
    }
  }

  void _onStepCountError(dynamic error) {
    debugPrint('[StepTracker] Step Count Sensor Error: $error');
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    debugPrint('[StepTracker] Pedestrian Status: ${event.status}');
    onPedestrianStatusChanged?.call(event.status);
  }

  void _onPedestrianStatusError(dynamic error) {
    debugPrint('[StepTracker] Pedestrian Status Sensor Error: $error');
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _isInitialized = false;
  }
}
