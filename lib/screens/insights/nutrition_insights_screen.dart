import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/fitness_provider.dart';

class NutritionInsightsScreen extends StatefulWidget {
  const NutritionInsightsScreen({super.key});

  @override
  State<NutritionInsightsScreen> createState() => _NutritionInsightsScreenState();
}

class _NutritionInsightsScreenState extends State<NutritionInsightsScreen> {
  int _selectedTab = 0; // 0: Daily, 1: Weekly, 2: Monthly
  DateTime _selectedDate = DateTime.now();
  int? _touchedBarIndex;

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessProvider>();

    // For non-today dates, we show 0 unless historical logs are available
    final hasRealData = _isToday;
    final int calories = hasRealData ? fitness.consumedCalories : 0;
    final int targetCalories = fitness.targetCalories;
    final double protein = hasRealData ? fitness.proteinConsumed : 0;
    final double carbs = hasRealData ? fitness.carbsConsumed : 0;
    final double fat = hasRealData ? fitness.fatConsumed : 0;
    final List<MealLogItem> meals = hasRealData ? fitness.todayMeals : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Nutrition Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Select Date',
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () => _pickDate(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date Switcher Bar (Left arrow, Date pill, Right arrow)
              _buildDateSelectorRow(),

              const SizedBox(height: 14),

              // 2. Period Selector Tabs (Daily, Weekly, Monthly)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Daily'),
                    _buildTabItem(1, 'Weekly'),
                    _buildTabItem(2, 'Monthly'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Calories Bar Chart Card (100% Dynamic based on real meals)
              _buildCaloriesChartCard(
                calories: calories,
                targetCalories: targetCalories,
                meals: meals,
              ),

              const SizedBox(height: 20),

              // 4. Macronutrients Donut Chart & Legend (100% Real Percentages)
              _buildMacronutrientsCard(
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),

              const SizedBox(height: 20),

              // 5. Logged Meals Breakdown for Selected Period
              _buildLoggedMealsSection(meals),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectorRow() {
    String dateLabel;
    if (_isToday) {
      dateLabel = 'Today, ${DateFormat('d MMM').format(_selectedDate)}';
    } else {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      if (_selectedDate.year == yesterday.year &&
          _selectedDate.month == yesterday.month &&
          _selectedDate.day == yesterday.day) {
        dateLabel = 'Yesterday, ${DateFormat('d MMM').format(_selectedDate)}';
      } else {
        dateLabel = DateFormat('EEE, d MMM yyyy').format(_selectedDate);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22, color: AppColors.textPrimary),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isToday)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                  },
                  child: const Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22, color: AppColors.textPrimary),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
              ),
            ],
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
            _touchedBarIndex = null;
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

  Widget _buildCaloriesChartCard({
    required int calories,
    required int targetCalories,
    required List<MealLogItem> meals,
  }) {
    // Dynamic Bar Groups calculation based on active tab and real data
    List<BarChartGroupData> barGroups = [];
    List<String> xLabels = [];
    String tooltipText = '$calories kcal';

    if (_selectedTab == 0) {
      // 1. DAILY VIEW: Categorized by Breakfast, Lunch, Snacks, Dinner
      int breakfastCals = 0;
      int lunchCals = 0;
      int snacksCals = 0;
      int dinnerCals = 0;

      for (final m in meals) {
        switch (m.category) {
          case MealCategory.breakfast:
            breakfastCals += m.calories;
            break;
          case MealCategory.lunch:
            lunchCals += m.calories;
            break;
          case MealCategory.snacks:
            snacksCals += m.calories;
            break;
          case MealCategory.dinner:
            dinnerCals += m.calories;
            break;
        }
      }

      final calsList = [breakfastCals, lunchCals, snacksCals, dinnerCals];
      xLabels = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

      int highestIndex = 0;
      int highestVal = 0;
      for (int i = 0; i < calsList.length; i++) {
        if (calsList[i] > highestVal) {
          highestVal = calsList[i];
          highestIndex = i;
        }
      }

      if (_touchedBarIndex != null && _touchedBarIndex! < calsList.length) {
        tooltipText = '${xLabels[_touchedBarIndex!]}: ${calsList[_touchedBarIndex!]} kcal';
      } else if (highestVal > 0) {
        tooltipText = '${xLabels[highestIndex]}: $highestVal kcal';
      }

      for (int i = 0; i < 4; i++) {
        final val = calsList[i].toDouble();
        final isHighest = val > 0 && i == highestIndex;
        barGroups.add(_makeBarGroup(i, val, isPeak: isHighest));
      }
    } else if (_selectedTab == 1) {
      // 2. WEEKLY VIEW: Mon to Sun
      xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final todayWeekdayIndex = DateTime.now().weekday - 1; // 0: Mon ... 6: Sun

      for (int i = 0; i < 7; i++) {
        double val = 0;
        if (_isToday && i == todayWeekdayIndex) {
          val = calories.toDouble();
        }
        barGroups.add(_makeBarGroup(i, val, isPeak: i == todayWeekdayIndex && val > 0));
      }
      if (_touchedBarIndex != null && _touchedBarIndex! < xLabels.length) {
        tooltipText = '${xLabels[_touchedBarIndex!]}: ${_touchedBarIndex == todayWeekdayIndex ? calories : 0} kcal';
      }
    } else {
      // 3. MONTHLY VIEW: 4 Weeks
      xLabels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
      final now = DateTime.now();
      final currentWeekIndex = ((now.day - 1) / 7).floor().clamp(0, 3);

      for (int i = 0; i < 4; i++) {
        double val = 0;
        if (_isToday && i == currentWeekIndex) {
          val = calories.toDouble();
        }
        barGroups.add(_makeBarGroup(i, val, isPeak: i == currentWeekIndex && val > 0));
      }
      if (_touchedBarIndex != null && _touchedBarIndex! < xLabels.length) {
        tooltipText = '${xLabels[_touchedBarIndex!]}: ${_touchedBarIndex == currentWeekIndex ? calories : 0} kcal';
      }
    }

    // Dynamic maxY based on data or target
    double maxBarVal = 0;
    for (final bg in barGroups) {
      for (final rod in bg.barRods) {
        if (rod.toY > maxBarVal) maxBarVal = rod.toY;
      }
    }
    final maxY = max(maxBarVal * 1.35, targetCalories.toDouble() > 0 ? targetCalories.toDouble() * 1.1 : 1500.0);

    return Container(
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
                    'Calories Consumed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calories.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} kcal',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Goal: $targetCalories kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Dynamic Active Tooltip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tooltipText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // FlChart Bar Chart
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (response != null && response.spot != null && event is FlTapUpEvent) {
                      setState(() {
                        _touchedBarIndex = response.spot!.touchedBarGroupIndex;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              xLabels[idx],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (maxY / 3).clamp(200.0, 1000.0),
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted));
                        if (val >= 1000) {
                          return Text('${(val / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                        }
                        return Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                    dashArray: value.toInt() == targetCalories ? [4, 4] : null,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientsCard({
    required double protein,
    required double carbs,
    required double fat,
  }) {
    final totalGrams = protein + carbs + fat;
    final int pPercent = totalGrams > 0 ? ((protein / totalGrams) * 100).round() : 0;
    final int cPercent = totalGrams > 0 ? ((carbs / totalGrams) * 100).round() : 0;
    final int fPercent = totalGrams > 0 ? (100 - pPercent - cPercent).clamp(0, 100) : 0;

    List<PieChartSectionData> pieSections;
    if (totalGrams > 0) {
      pieSections = [
        PieChartSectionData(
          color: AppColors.primary,
          value: max(protein, 1.0),
          radius: 18,
          showTitle: false,
        ),
        PieChartSectionData(
          color: AppColors.protein,
          value: max(carbs, 1.0),
          radius: 18,
          showTitle: false,
        ),
        PieChartSectionData(
          color: AppColors.fat,
          value: max(fat, 1.0),
          radius: 18,
          showTitle: false,
        ),
      ];
    } else {
      pieSections = [
        PieChartSectionData(
          color: AppColors.borderLight,
          value: 100,
          radius: 18,
          showTitle: false,
        ),
      ];
    }

    return Container(
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
            'Macronutrients Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // Dynamic Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        startDegreeOffset: -90,
                        sections: pieSections,
                      ),
                    ),
                    Text(
                      totalGrams > 0 ? '${totalGrams.toInt()}g' : '0g',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Dynamic Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      'Protein',
                      '${protein.toStringAsFixed(protein % 1 == 0 ? 0 : 1)}g',
                      '$pPercent%',
                      AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      'Carbs',
                      '${carbs.toStringAsFixed(carbs % 1 == 0 ? 0 : 1)}g',
                      '$cPercent%',
                      AppColors.protein,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      'Fat',
                      '${fat.toStringAsFixed(fat % 1 == 0 ? 0 : 1)}g',
                      '$fPercent%',
                      AppColors.fat,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedMealsSection(List<MealLogItem> meals) {
    if (meals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Column(
          children: [
            Icon(Icons.restaurant_outlined, size: 36, color: AppColors.textMuted),
            SizedBox(height: 10),
            Text(
              'No Meals Logged for this Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Scan or log your meal to view detailed nutritional analytics.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
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
              const Text(
                'Logged Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${meals.length} item${meals.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...meals.map((meal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(meal.emoji ?? '🍽️', style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meal.category.title} • ${meal.time}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${meal.calories} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'P:${meal.protein.toInt()}g  C:${meal.carbs.toInt()}g  F:${meal.fat.toInt()}g',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, {bool isPeak = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isPeak ? AppColors.primary : AppColors.primary.withValues(alpha: y > 0 ? 0.6 : 0.15),
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String name, String amount, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '$amount ($percent)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
