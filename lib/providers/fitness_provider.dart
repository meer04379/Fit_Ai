import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/step_tracker_service.dart';

class FitnessProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  final StepTrackerService _stepTracker = StepTrackerService();

  FitnessProvider() {
    _initStepTracker();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSteps = prefs.getInt('steps_target');
      if (savedSteps != null && savedSteps > 0) {
        _stepsTarget = savedSteps;
      }
      final savedCurrentW = prefs.getDouble('current_weight');
      if (savedCurrentW != null && savedCurrentW > 0) {
        _currentWeight = savedCurrentW;
      }
      final savedStartW = prefs.getDouble('starting_weight');
      if (savedStartW != null && savedStartW > 0) {
        _startingWeight = savedStartW;
      } else {
        _startingWeight = _currentWeight;
      }
      final savedGoalW = prefs.getDouble('goal_weight');
      if (savedGoalW != null && savedGoalW > 0) {
        _goalWeight = savedGoalW;
      }
      final savedWorkouts = prefs.getInt('completed_workouts_this_week');
      if (savedWorkouts != null) {
        _completedWorkoutsThisWeek = savedWorkouts;
      }
      final historyStrings = prefs.getStringList('weight_history');
      if (historyStrings != null && historyStrings.isNotEmpty) {
        _weightHistory = historyStrings.map((s) {
          final parts = s.split(':');
          return WeightDataPoint(
            label: parts[0],
            weight: double.tryParse(parts[1]) ?? _currentWeight,
          );
        }).toList();
      } else {
        _weightHistory = [
          WeightDataPoint(label: 'Start', weight: _startingWeight),
          WeightDataPoint(label: 'Today', weight: _currentWeight),
        ];
      }

      final savedMealsJson = prefs.getString('saved_today_meals');
      if (savedMealsJson != null && savedMealsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedMealsJson);
        _todayMeals = decoded
            .map((m) => MealLogItem.fromSupabaseMap(Map<String, dynamic>.from(m as Map)))
            .toList();
        _recalculateNutrition();
      }

      _recalculateProgress();
      notifyListeners();
    } catch (e) {
      debugPrint('[FitnessProvider] Could not load saved fitness data: $e');
    }
  }

  void _recalculateProgress() {
    if (_selectedGoal == GoalType.loseWeight) {
      final totalToLose = _startingWeight - _goalWeight;
      final lostSoFar = _startingWeight - _currentWeight;
      if (totalToLose > 0.1) {
        _progressPercentage = ((lostSoFar / totalToLose) * 100).round().clamp(0, 100);
      } else {
        _progressPercentage = 0;
      }
    } else if (_selectedGoal == GoalType.gainMuscle) {
      final totalToGain = _goalWeight - _startingWeight;
      final gainedSoFar = _currentWeight - _startingWeight;
      if (totalToGain > 0.1) {
        _progressPercentage = ((gainedSoFar / totalToGain) * 100).round().clamp(0, 100);
      } else {
        _progressPercentage = 0;
      }
    } else {
      _progressPercentage = 100;
    }
  }

  void _initStepTracker() {
    _stepTracker.init(
      onSteps: (steps) {
        _stepsCount = steps;
        _isLivePedometerActive = true;
        notifyListeners();
      },
      onStatus: (status) {
        _pedestrianStatus = status;
        notifyListeners();
      },
    );
  }

  // Live Pedometer Sensor State
  bool _isLivePedometerActive = false;
  String _pedestrianStatus = 'stopped'; // 'walking', 'stopped', 'unknown'

  // User Profile & Goals
  String _userName = 'Athlete';
  GoalType _selectedGoal = GoalType.gainMuscle;

  // Calorie & Macro Targets
  int _targetCalories = 2000;
  int _consumedCalories = 1240;

  double _proteinTarget = 120;
  double _proteinConsumed = 62;

  double _carbsTarget = 250;
  double _carbsConsumed = 140;

  double _fatTarget = 65;
  double _fatConsumed = 42;

  // Activity Tracking
  int _waterGlasses = 6;
  int _waterTarget = 8;
  int _stepsCount = 0;
  int _stepsTarget = 10000;

  // Weight & Progress
  double _startingWeight = 72.0;
  double _currentWeight = 70.5;
  double _goalWeight = 65.0;
  int _progressPercentage = 0;
  int _completedWorkoutsThisWeek = 0;
  List<WeightDataPoint> _weightHistory = [];

  // Meals Logged Today
  List<MealLogItem> _todayMeals = [
    const MealLogItem(
      id: 'meal_1',
      title: 'Oats with Fruits',
      category: MealCategory.breakfast,
      calories: 420,
      time: '8:30 AM',
      emoji: '🥣',
      protein: 14,
      carbs: 65,
      fat: 8,
      aiConfidence: 98,
      ingredients: [
        DetectedIngredient(name: 'Rolled Oats', calories: 250, icon: '🌾'),
        DetectedIngredient(name: 'Banana & Berries', calories: 120, icon: '🍌'),
        DetectedIngredient(name: 'Almond Milk', calories: 50, icon: '🥛'),
      ],
    ),
    const MealLogItem(
      id: 'meal_2',
      title: 'Chicken Biryani',
      category: MealCategory.lunch,
      calories: 620,
      time: '1:30 PM',
      emoji: '🍛',
      protein: 28,
      carbs: 72,
      fat: 24,
      aiConfidence: 94,
      ingredients: [
        DetectedIngredient(name: 'Chicken', calories: 180, icon: '🍗'),
        DetectedIngredient(name: 'Rice', calories: 350, icon: '🍚'),
        DetectedIngredient(name: 'Vegetables', calories: 40, icon: '🥗'),
        DetectedIngredient(name: 'Oil / Spices', calories: 50, icon: '🧂'),
      ],
    ),
    const MealLogItem(
      id: 'meal_3',
      title: 'Protein Shake',
      category: MealCategory.snacks,
      calories: 180,
      time: '5:30 PM',
      emoji: '🥤',
      protein: 20,
      carbs: 3,
      fat: 10,
      aiConfidence: 99,
      ingredients: [
        DetectedIngredient(name: 'Whey Protein', calories: 140, icon: '🥛'),
        DetectedIngredient(name: 'Peanut Butter', calories: 40, icon: '🥜'),
      ],
    ),
  ];

  // Getters
  String get userName => _userName;
  GoalType get selectedGoal => _selectedGoal;
  int get targetCalories => _targetCalories;
  int get consumedCalories => _consumedCalories;
  int get remainingCalories => _targetCalories - _consumedCalories > 0 ? _targetCalories - _consumedCalories : 0;
  double get calorieRatio => (_consumedCalories / _targetCalories).clamp(0.0, 1.0);
  int get caloriePercentage => ((_consumedCalories / _targetCalories) * 100).toInt();

  double get proteinTarget => _proteinTarget;
  double get proteinConsumed => _proteinConsumed;
  double get proteinRatio => (_proteinConsumed / _proteinTarget).clamp(0.0, 1.0);

  double get carbsTarget => _carbsTarget;
  double get carbsConsumed => _carbsConsumed;
  double get carbsRatio => (_carbsConsumed / _carbsTarget).clamp(0.0, 1.0);

  double get fatTarget => _fatTarget;
  double get fatConsumed => _fatConsumed;
  double get fatRatio => (_fatConsumed / _fatTarget).clamp(0.0, 1.0);

  int get waterGlasses => _waterGlasses;
  int get waterTarget => _waterTarget;
  int get stepsCount => _stepsCount;
  int get stepsTarget => _stepsTarget;
  bool get isLivePedometerActive => _isLivePedometerActive;
  String get pedestrianStatus => _pedestrianStatus;
  double get stepsRatio => (_stepsCount / _stepsTarget).clamp(0.0, 1.0);
  double get waterRatio => (_waterGlasses / _waterTarget).clamp(0.0, 1.0);

  double get currentWeight => _currentWeight;
  double get startingWeight => _startingWeight;
  double get goalWeight => _goalWeight;
  int get progressPercentage => _progressPercentage;
  int get completedWorkoutsThisWeek => _completedWorkoutsThisWeek;
  List<WeightDataPoint> get weightHistory => List.unmodifiable(_weightHistory);
  List<MealLogItem> get todayMeals => List.unmodifiable(_todayMeals);

  /// Synchronize initial data from Supabase Cloud if available
  Future<void> syncFromCloud() async {
    // 1. Fetch profile from Supabase
    final profile = await _supabase.fetchProfile();
    if (profile != null) {
      if (profile['name'] != null && (profile['name'] as String).isNotEmpty) {
        _userName = profile['name'];
      }
      if (profile['goal'] != null) {
        _selectedGoal = GoalType.values.firstWhere(
          (g) => g.name == profile['goal'],
          orElse: () => GoalType.gainMuscle,
        );
      }
      if (profile['target_calories'] != null) {
        _targetCalories = (profile['target_calories'] as num).toInt();
      }
      if (profile['current_weight'] != null) {
        _currentWeight = (profile['current_weight'] as num).toDouble();
      }
      if (profile['goal_weight'] != null) {
        _goalWeight = (profile['goal_weight'] as num).toDouble();
      }
    }

    // 2. Fetch meals
    final cloudMeals = await _supabase.fetchTodayMeals();
    if (cloudMeals != null) {
      _todayMeals = cloudMeals;
      _recalculateNutrition();
    }
    notifyListeners();
  }

  /// Resets daily meal counts and stats for a fresh new user experience
  void clearForNewUser() {
    _todayMeals = [];
    _consumedCalories = 0;
    _proteinConsumed = 0;
    _carbsConsumed = 0;
    _fatConsumed = 0;
    _waterGlasses = 0;
    _stepsCount = 0;
    _progressPercentage = 0;
    _stepTracker.resetBaseline(0);
    try {
      SharedPreferences.getInstance().then((prefs) => prefs.remove('saved_today_meals'));
    } catch (_) {}
    notifyListeners();
  }

  Future<void> resetStepsToZero() async {
    _stepsCount = 0;
    await _stepTracker.resetBaseline(0);
    notifyListeners();
  }

  /// Applies personalized profile targets and saves to Supabase
  Future<void> applyProfileSetup({
    required GoalType goal,
    required int targetCalories,
    required double proteinTarget,
    required double carbsTarget,
    required double fatTarget,
    required double currentWeight,
    required double goalWeight,
    int? stepsTarget,
  }) async {
    _selectedGoal = goal;
    _targetCalories = targetCalories;
    _proteinTarget = proteinTarget;
    _carbsTarget = carbsTarget;
    _fatTarget = fatTarget;
    _currentWeight = currentWeight;
    _startingWeight = currentWeight;
    _goalWeight = goalWeight;
    _progressPercentage = 0;
    _weightHistory = [
      WeightDataPoint(label: 'Start', weight: currentWeight),
      WeightDataPoint(label: 'Today', weight: currentWeight),
    ];
    if (stepsTarget != null && stepsTarget > 0) {
      _stepsTarget = stepsTarget;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('steps_target', stepsTarget);
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_weight', currentWeight);
      await prefs.setDouble('starting_weight', currentWeight);
      await prefs.setDouble('goal_weight', goalWeight);
    } catch (_) {}

    notifyListeners();

    await _supabase.saveProfile(
      name: _userName,
      goal: _selectedGoal.name,
      targetCalories: _targetCalories,
      currentWeight: _currentWeight,
      goalWeight: _goalWeight,
    );
  }

  /// Logs out and resets to guest state
  Future<void> logout() async {
    await _supabase.signOut();
    _userName = 'Athlete';
    clearForNewUser();
  }

  void _recalculateNutrition() {
    int totalCals = 0;
    double totalP = 0;
    double totalC = 0;
    double totalF = 0;

    for (final m in _todayMeals) {
      totalCals += m.calories;
      totalP += m.protein;
      totalC += m.carbs;
      totalF += m.fat;
    }

    _consumedCalories = totalCals;
    _proteinConsumed = totalP;
    _carbsConsumed = totalC;
    _fatConsumed = totalF;
  }

  // Setters & Actions
  void setUserName(String name) {
    _userName = name;
    _supabase.saveProfile(
      name: _userName,
      goal: _selectedGoal.name,
      targetCalories: _targetCalories,
      currentWeight: _currentWeight,
      goalWeight: _goalWeight,
    );
    notifyListeners();
  }

  void setGoal(GoalType goal) {
    _selectedGoal = goal;
    _supabase.saveProfile(
      name: _userName,
      goal: _selectedGoal.name,
      targetCalories: _targetCalories,
      currentWeight: _currentWeight,
      goalWeight: _goalWeight,
    );
    notifyListeners();
  }

  void setTargets({int? targetCalories, double? protein, double? carbs, double? fat, int? water, int? steps}) {
    if (targetCalories != null) _targetCalories = targetCalories;
    if (protein != null) _proteinTarget = protein;
    if (carbs != null) _carbsTarget = carbs;
    if (fat != null) _fatTarget = fat;
    if (water != null) _waterTarget = water;
    if (steps != null) _stepsTarget = steps;
    notifyListeners();
  }

  void addSteps(int steps) {
    _stepsCount += steps;
    notifyListeners();
  }

  void setSteps(int steps) {
    _stepsCount = steps;
    _stepTracker.resetBaseline(steps);
    notifyListeners();
  }

  Future<void> setStepsTarget(int target) async {
    if (target > 0) {
      _stepsTarget = target;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('steps_target', target);
      } catch (e) {
        debugPrint('[FitnessProvider] Error persisting steps_target: $e');
      }
    }
  }

  void setWaterGlasses(int count) {
    _waterGlasses = count.clamp(0, 50);
    notifyListeners();
  }

  void refreshStepTracker() {
    _stepTracker.init(
      onSteps: (steps) {
        _stepsCount = steps;
        _isLivePedometerActive = true;
        notifyListeners();
      },
      onStatus: (status) {
        _pedestrianStatus = status;
        notifyListeners();
      },
    );
  }

  void updateWeight({double? current, double? goal, int? progress}) {
    if (current != null) {
      _currentWeight = current;
      _supabase.logWeight(current);
    }
    if (goal != null) _goalWeight = goal;
    if (progress != null) _progressPercentage = progress;
    notifyListeners();
  }

  Future<void> logNewWeight(double newWeight) async {
    _currentWeight = newWeight;
    final now = DateTime.now();
    final dateLabel = '${now.day}/${now.month}';

    _weightHistory.add(WeightDataPoint(label: dateLabel, weight: newWeight));
    if (_weightHistory.length > 7) {
      _weightHistory = _weightHistory.sublist(_weightHistory.length - 7);
    }

    _recalculateProgress();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_weight', newWeight);
      final historyList = _weightHistory.map((dp) => '${dp.label}:${dp.weight}').toList();
      await prefs.setStringList('weight_history', historyList);
    } catch (_) {}

    _supabase.logWeight(newWeight);
    _supabase.saveProfile(
      name: _userName,
      goal: _selectedGoal.name,
      targetCalories: _targetCalories,
      currentWeight: _currentWeight,
      goalWeight: _goalWeight,
    );
  }

  Future<void> completeWorkout() async {
    _completedWorkoutsThisWeek = (_completedWorkoutsThisWeek + 1).clamp(0, 5);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completed_workouts_this_week', _completedWorkoutsThisWeek);
    } catch (_) {}
  }

  void addWater() {
    if (_waterGlasses < _waterTarget + 4) {
      _waterGlasses++;
      notifyListeners();
    }
  }

  void removeWater() {
    if (_waterGlasses > 0) {
      _waterGlasses--;
      notifyListeners();
    }
  }

  void addMeal(MealLogItem meal) {
    _todayMeals.add(meal);
    _consumedCalories += meal.calories;
    _proteinConsumed += meal.protein;
    _carbsConsumed += meal.carbs;
    _fatConsumed += meal.fat;
    notifyListeners();

    _persistMealsLocally();
    // Async sync to Supabase
    _supabase.saveMeal(meal);
  }

  void deleteMeal(String mealId) {
    final index = _todayMeals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      final meal = _todayMeals[index];
      _consumedCalories -= meal.calories;
      _proteinConsumed -= meal.protein;
      _carbsConsumed -= meal.carbs;
      _fatConsumed -= meal.fat;
      _todayMeals.removeAt(index);
      notifyListeners();

      _persistMealsLocally();
      // Async sync to Supabase
      _supabase.deleteMeal(mealId);
    }
  }

  Future<void> _persistMealsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _todayMeals.map((m) => m.toSupabaseMap('local_user')).toList();
      await prefs.setString('saved_today_meals', jsonEncode(list));
    } catch (e) {
      debugPrint('[FitnessProvider] Error persisting meals locally: $e');
    }
  }
}
