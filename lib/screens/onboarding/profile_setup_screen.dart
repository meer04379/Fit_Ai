import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/fitness_provider.dart';
import '../main_nav_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  final GoalType selectedGoal;

  const ProfileSetupScreen({
    super.key,
    required this.selectedGoal,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _gender = 'Male';
  int _age = 25;
  double _heightCm = 175;
  double _currentWeight = 72.0;
  double _goalWeight = 68.0;
  int _stepTarget = 10000;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final fitness = context.read<FitnessProvider>();
    _currentWeight = fitness.currentWeight;
    _stepTarget = fitness.stepsTarget;
    _goalWeight = widget.selectedGoal == GoalType.loseWeight
        ? _currentWeight - 4
        : widget.selectedGoal == GoalType.gainMuscle
            ? _currentWeight + 3
            : _currentWeight;
  }

  // Live calculation of BMR & Targets
  int get _calculatedTargetCalories {
    // Mifflin-St Jeor formula
    double bmr;
    if (_gender == 'Male') {
      bmr = (10 * _currentWeight) + (6.25 * _heightCm) - (5 * _age) + 5;
    } else {
      bmr = (10 * _currentWeight) + (6.25 * _heightCm) - (5 * _age) - 161;
    }

    // Moderate activity multiplier (1.375)
    double tdee = bmr * 1.375;

    switch (widget.selectedGoal) {
      case GoalType.loseWeight:
        return (tdee - 450).round().clamp(1200, 3500);
      case GoalType.gainMuscle:
        return (tdee + 350).round().clamp(1800, 4200);
      case GoalType.maintain:
        return tdee.round().clamp(1500, 3800);
    }
  }

  double get _calculatedProtein {
    final factor = widget.selectedGoal == GoalType.gainMuscle ? 2.0 : 1.6;
    return (_currentWeight * factor).roundToDouble();
  }

  double get _calculatedCarbs {
    final proteinCals = _calculatedProtein * 4;
    final remainingCals = _calculatedTargetCalories - proteinCals - (_calculatedFat * 9);
    return (remainingCals / 4).clamp(80, 500).roundToDouble();
  }

  double get _calculatedFat {
    return (_calculatedTargetCalories * 0.25 / 9).clamp(35, 120).roundToDouble();
  }

  Future<void> _completeSetup() async {
    setState(() => _isSaving = true);

    try {
      final fitness = context.read<FitnessProvider>();
      await fitness.applyProfileSetup(
        goal: widget.selectedGoal,
        targetCalories: _calculatedTargetCalories,
        proteinTarget: _calculatedProtein,
        carbsTarget: _calculatedCarbs,
        fatTarget: _calculatedFat,
        currentWeight: _currentWeight,
        goalWeight: _goalWeight,
        stepsTarget: _stepTarget,
      );
    } catch (e) {
      debugPrint('[ProfileSetup] Save error: $e');
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calories = _calculatedTargetCalories;
    final protein = _calculatedProtein;
    final carbs = _calculatedCarbs;
    final fat = _calculatedFat;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personalize Your Plan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Let AI tailor your nutrition targets for ${widget.selectedGoal.title}.',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Gender Selector
              const Text('Gender', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildGenderOption('Male', '👨')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderOption('Female', '👩')),
                ],
              ),

              const SizedBox(height: 20),

              // Sliders: Age & Height
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInputCard(
                      title: 'Age',
                      value: '$_age',
                      unit: 'yrs',
                      onMinus: () => setState(() => _age = (_age - 1).clamp(14, 85)),
                      onPlus: () => setState(() => _age = (_age + 1).clamp(14, 85)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInputCard(
                      title: 'Height',
                      value: '${_heightCm.toInt()}',
                      unit: 'cm',
                      onMinus: () => setState(() => _heightCm = (_heightCm - 1).clamp(120, 230)),
                      onPlus: () => setState(() => _heightCm = (_heightCm + 1).clamp(120, 230)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sliders: Current Weight & Goal Weight
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInputCard(
                      title: 'Current Weight',
                      value: _currentWeight.toStringAsFixed(1),
                      unit: 'kg',
                      onMinus: () => setState(() => _currentWeight = (_currentWeight - 0.5).clamp(35, 200)),
                      onPlus: () => setState(() => _currentWeight = (_currentWeight + 0.5).clamp(35, 200)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInputCard(
                      title: 'Target Weight',
                      value: _goalWeight.toStringAsFixed(1),
                      unit: 'kg',
                      onMinus: () => setState(() => _goalWeight = (_goalWeight - 0.5).clamp(35, 200)),
                      onPlus: () => setState(() => _goalWeight = (_goalWeight + 0.5).clamp(35, 200)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // AI Live Calorie & Macro Target Calculation Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Your AI Daily Target',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$calories',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'kcal / day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroPill('Protein', '${protein.toInt()}g', AppColors.protein),
                        _buildMacroPill('Carbs', '${carbs.toInt()}g', AppColors.carbs),
                        _buildMacroPill('Fat', '${fat.toInt()}g', AppColors.fat),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Daily Step Target Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daily Step Target', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(
                    '$_stepTarget steps',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStepOption(6000, '6,000', 'Light'),
                  const SizedBox(width: 8),
                  _buildStepOption(8000, '8,000', 'Moderate'),
                  const SizedBox(width: 8),
                  _buildStepOption(10000, '10,000', 'Active ★'),
                  const SizedBox(width: 8),
                  _buildStepOption(12000, '12,000', 'Athletic'),
                ],
              ),

              const SizedBox(height: 28),

              // Complete Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text(
                          'Start My Fitness Journey 🚀',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, String emoji) {
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepOption(int target, String label, String subtitle) {
    final isSelected = _stepTarget == target;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _stepTarget = target),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInputCard({
    required String title,
    required String value,
    required String unit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textSecondary),
                onPressed: onMinus,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String title, String grams, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(grams, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
