import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../models/workout_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/fitness_provider.dart';
import '../auth/auth_screen.dart';

class ProgressScreen extends StatefulWidget {
  final int initialTab;
  const ProgressScreen({super.key, this.initialTab = 0});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Weight, 2: Workouts
  bool _isGymWorkout = false; // false: Home, true: Gym
  late int _selectedWeekday; // 1: Mon ... 7: Sun
  final Set<String> _completedExercises = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _selectedWeekday = DateTime.now().weekday;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out of FitAI?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<FitnessProvider>().logout();
              if (context.mounted) {
                context.read<ChatProvider>().clearChat('Athlete');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogWeightDialog(FitnessProvider fitness) {
    final TextEditingController weightCtrl =
        TextEditingController(text: fitness.currentWeight.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final currentVal = double.tryParse(weightCtrl.text) ?? fitness.currentWeight;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Log Today\'s Weight',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Record your weight to update your transformation chart and progress percentage.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Weight Display / Input
                Center(
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Quick Increment / Decrement Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDeltaChip('-0.5', () {
                      setSheetState(() {
                        weightCtrl.text = (currentVal - 0.5).toStringAsFixed(1);
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildDeltaChip('-0.2', () {
                      setSheetState(() {
                        weightCtrl.text = (currentVal - 0.2).toStringAsFixed(1);
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildDeltaChip('+0.2', () {
                      setSheetState(() {
                        weightCtrl.text = (currentVal + 0.2).toStringAsFixed(1);
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildDeltaChip('+0.5', () {
                      setSheetState(() {
                        weightCtrl.text = (currentVal + 0.5).toStringAsFixed(1);
                      });
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final parsed = double.tryParse(weightCtrl.text.trim());
                      if (parsed != null && parsed >= 30.0 && parsed <= 300.0) {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        await fitness.logNewWeight(parsed);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Weight logged successfully: ${parsed.toStringAsFixed(1)} kg 🎉'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Weight Entry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeltaChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'My Progress & Workouts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.textSecondary),
            tooltip: 'Log out',
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Banner Card
              _buildProfileBanner(fitness),

              // Segmented Tabs (0: Overview, 1: Weight, 2: Workouts)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Overview'),
                    _buildTabItem(1, 'Weight'),
                    _buildTabItem(2, 'Workouts'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic Tab Content
              if (_selectedTab == 0) _buildOverviewTab(fitness),
              if (_selectedTab == 1) _buildWeightTab(fitness),
              if (_selectedTab == 2) _buildWorkoutsTab(fitness),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBanner(FitnessProvider fitness) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              fitness.userName.isNotEmpty ? fitness.userName[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fitness.userName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Goal: ${fitness.selectedGoal.title} • ${fitness.targetCalories} kcal/day',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${fitness.progressPercentage}% Goal',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? AppColors.softShadow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------- TAB 0: OVERVIEW -------------------------
  Widget _buildOverviewTab(FitnessProvider fitness) {
    final double diff = fitness.currentWeight - fitness.startingWeight;
    final String diffStr = diff > 0
        ? '+${diff.toStringAsFixed(1)} kg'
        : diff < 0
            ? '${diff.toStringAsFixed(1)} kg'
            : '0.0 kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Stat Cards
        Row(
          children: [
            _buildStatCard('Current', '${fitness.currentWeight.toStringAsFixed(1)} kg'),
            const SizedBox(width: 10),
            _buildStatCard('Goal', '${fitness.goalWeight.toStringAsFixed(1)} kg'),
            const SizedBox(width: 10),
            _buildStatCard('Progress', '${fitness.progressPercentage}%', isHighlight: true),
          ],
        ),

        const SizedBox(height: 20),

        // Weight Progress Card with Line Chart & Log Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight Progress',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$diffStr from start (${fitness.startingWeight.toStringAsFixed(1)} kg)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showLogWeightDialog(fitness),
                    icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    label: const Text('Log Weight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildWeightLineChart(fitness),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Workout Consistency & Quick Jump Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Workout Streak',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fitness.completedWorkoutsThisWeek} / 5 Days Completed',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (idx) {
                      final isDone = idx < fitness.completedWorkoutsThisWeek;
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 10,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primary : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 2; // Jump to Workouts Tab
                    });
                  },
                  icon: const Icon(Icons.fitness_center_rounded, size: 18),
                  label: const Text('View Today\'s Workout Routine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------- TAB 1: WEIGHT TRACKER -------------------------
  Widget _buildWeightTab(FitnessProvider fitness) {
    final double diff = fitness.currentWeight - fitness.startingWeight;
    final String diffStr = diff > 0
        ? '+${diff.toStringAsFixed(1)} kg'
        : diff < 0
            ? '${diff.toStringAsFixed(1)} kg'
            : '0.0 kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Weight Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight Transformation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      diffStr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeightInfoBlock('Starting', '${fitness.startingWeight.toStringAsFixed(1)} kg'),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textMuted),
                  _buildWeightInfoBlock('Current', '${fitness.currentWeight.toStringAsFixed(1)} kg', isPrimary: true),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textMuted),
                  _buildWeightInfoBlock('Goal', '${fitness.goalWeight.toStringAsFixed(1)} kg'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogWeightDialog(fitness),
                  icon: const Icon(Icons.scale_rounded, size: 20),
                  label: const Text('Log Today\'s Weight (Check-in)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Line Chart Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weight Trend Graph',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track changes over time from your check-ins.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _buildWeightLineChart(fitness),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Check-in Log History
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Check-ins',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ...fitness.weightHistory.reversed.map((dp) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text(dp.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text(
                        '${dp.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInfoBlock(String label, String value, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 18 : 15,
            fontWeight: FontWeight.w800,
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ------------------------- TAB 2: WORKOUTS (HOME & GYM) -------------------------
  Widget _buildWorkoutsTab(FitnessProvider fitness) {
    final DailyWorkoutPlan currentPlan = WorkoutDatabase.getWorkoutForDay(
      weekday: _selectedWeekday,
      isGym: _isGymWorkout,
    );

    final bool isCurrentDayToday = _selectedWeekday == DateTime.now().weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Home vs Gym Mode Toggle Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGymWorkout = false;
                      _completedExercises.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isGymWorkout ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏠', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Home Workout (Ghar)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: !_isGymWorkout ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGymWorkout = true;
                      _completedExercises.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isGymWorkout ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏋️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Gym Workout',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isGymWorkout ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. 7-Day Weekday Pill Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(7, (idx) {
              final dayIndex = idx + 1; // 1: Mon ... 7: Sun
              const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final isSelected = _selectedWeekday == dayIndex;
              final isToday = DateTime.now().weekday == dayIndex;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeekday = dayIndex;
                      _completedExercises.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          names[idx],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 18),

        // 3. Today's Plan Highlight Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isGymWorkout ? const Color(0xFF1E293B) : const Color(0xFF064E3B),
                _isGymWorkout ? const Color(0xFF0F172A) : const Color(0xFF022C22),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCurrentDayToday ? 'TODAY\'S WORKOUT' : currentPlan.dayName.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text('${currentPlan.durationMinutes} mins', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_fire_department_rounded, size: 15, color: Colors.amberAccent),
                      const SizedBox(width: 3),
                      Text('~${currentPlan.estimatedCalories} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.amberAccent)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currentPlan.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Focus: ${currentPlan.focusArea}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 4. List of Exercises with Sets & Reps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercises & Sets',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              '${_completedExercises.length} / ${currentPlan.exercises.length} Done',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ...currentPlan.exercises.map((exercise) {
          final isChecked = _completedExercises.contains(exercise.name);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isChecked ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Emoji / Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(exercise.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),

                // Name & Reps
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exercise.setsAndReps,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            exercise.targetMuscle,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      if (exercise.tip.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '💡 ${exercise.tip}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),

                // Checkbox
                IconButton(
                  icon: Icon(
                    isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isChecked ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isChecked) {
                        _completedExercises.remove(exercise.name);
                      } else {
                        _completedExercises.add(exercise.name);
                      }
                    });
                  },
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),

        // Mark Entire Workout Completed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await fitness.completeWorkout();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Fantastic! Today\'s workout logged and weekly streak increased!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.done_all_rounded, size: 20),
            label: const Text('Complete Today\'s Workout (Log Streak)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------- SHARED LINE CHART -------------------------
  Widget _buildWeightLineChart(FitnessProvider fitness) {
    final List<WeightDataPoint> history = fitness.weightHistory.isNotEmpty
        ? fitness.weightHistory
        : [
            WeightDataPoint(label: 'Start', weight: fitness.startingWeight),
            WeightDataPoint(label: 'Today', weight: fitness.currentWeight),
          ];

    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].weight));
    }

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2.0;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2.0;
    if ((maxY - minY).abs() < 2.0) {
      minY -= 1.5;
      maxY += 1.5;
    }

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.borderLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (val, meta) {
                  if (val == meta.min || val == meta.max) return const SizedBox();
                  return Text(
                    '${val.toInt()}kg',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  );
                },
                reservedSize: 32,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < history.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        history[idx].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: idx == history.length - 1 ? FontWeight.w700 : FontWeight.w500,
                          color: idx == history.length - 1 ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 24,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (history.length - 1).toDouble() > 0 ? (history.length - 1).toDouble() : 1.0,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
