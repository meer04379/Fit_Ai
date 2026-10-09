import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/circular_progress_widget.dart';
import '../../widgets/meal_card.dart';
import '../scanner/food_scanner_screen.dart';

class TodaysMealsScreen extends StatelessWidget {
  const TodaysMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Today's Meals",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing Today\'s Log')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Total Calories Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Calories',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${fitness.consumedCalories.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '/ ${fitness.targetCalories.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} kcal',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    CircularProgressWidget(
                      percent: fitness.calorieRatio,
                      percentageText: fitness.caloriePercentage,
                      subText: '',
                      radius: 34,
                      lineWidth: 6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Meal Timeline Sections
              _buildMealSection(
                context,
                title: 'Breakfast',
                category: MealCategory.breakfast,
                fitness: fitness,
              ),

              const SizedBox(height: 12),

              _buildMealSection(
                context,
                title: 'Lunch',
                category: MealCategory.lunch,
                fitness: fitness,
              ),

              const SizedBox(height: 12),

              _buildMealSection(
                context,
                title: 'Dinner',
                category: MealCategory.dinner,
                fitness: fitness,
              ),

              const SizedBox(height: 12),

              _buildMealSection(
                context,
                title: 'Snacks',
                category: MealCategory.snacks,
                fitness: fitness,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context, {
    required String title,
    required MealCategory category,
    required FitnessProvider fitness,
  }) {
    final meals = fitness.todayMeals.where((m) => m.category == category).toList();

    if (meals.isEmpty) {
      // Empty Add Action Row (e.g. Dinner in design)
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodScannerScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.textMuted, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 18, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Add your $title',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...meals.map(
          (m) => MealCard(
            meal: m,
            onDelete: () => fitness.deleteMeal(m.id),
          ),
        ),
      ],
    );
  }
}
