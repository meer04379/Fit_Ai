import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/custom_button.dart';

class AnalysisResultScreen extends StatelessWidget {
  final MealLogItem? customResult;
  final Uint8List? imageBytes;
  final String? imagePath;

  const AnalysisResultScreen({
    super.key,
    this.customResult,
    this.imageBytes,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Default chicken biryani result from design
    final meal = customResult ??
        const MealLogItem(
          id: 'scanned_meal_biryani',
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
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal analysis copied to clipboard')),
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
              // 1. Food Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    // Food Image Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildThumbnail(),
                    ),
                    const SizedBox(width: 16),

                    // Title, Calories, and AI Confidence
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${meal.calories}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' kcal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AI Confidence: ${meal.aiConfidence}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Nutrition Summary (Approx.)
              const Text(
                'Nutrition Summary (Approx.)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutritionMetric('Protein', '${meal.protein.toInt()}g', AppColors.protein),
                    Container(height: 36, width: 1, color: AppColors.borderLight),
                    _buildNutritionMetric('Carbs', '${meal.carbs.toInt()}g', AppColors.carbs),
                    Container(height: 36, width: 1, color: AppColors.borderLight),
                    _buildNutritionMetric('Fat', '${meal.fat.toInt()}g', AppColors.fat),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Detected Items Section
              const Text(
                'Detected Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: List.generate(meal.ingredients.length, (index) {
                    final item = meal.ingredients[index];
                    final isLast = index == meal.ingredients.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(item.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.calories} kcal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, color: AppColors.borderLight),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // 4. Add to Today's Log Button
              CustomButton(
                text: "Add to Today's Log",
                onPressed: () {
                  context.read<FitnessProvider>().addMeal(meal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal logged successfully! 🎉'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionMetric(String title, String value, Color indicatorColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }
    if (imagePath != null && !kIsWeb) {
      return Image.file(
        File(imagePath!),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=400&auto=format&fit=crop',
      width: 90,
      height: 90,
      fit: BoxFit.cover,
    );
  }
}
