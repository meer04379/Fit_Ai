import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../services/gemini_service.dart';
import 'analysis_result_screen.dart';

class AnalyzingMealScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? imagePath;

  const AnalyzingMealScreen({
    super.key,
    this.imageBytes,
    this.imagePath,
  });

  @override
  State<AnalyzingMealScreen> createState() => _AnalyzingMealScreenState();
}

class _AnalyzingMealScreenState extends State<AnalyzingMealScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _currentStep = 0;
  Timer? _stepTimer;
  MealLogItem? _analyzedMeal;
  bool _isGeminiDone = false;

  final List<String> _steps = [
    'Detecting food items',
    'Estimating portion size',
    'Calculating calories',
    'Analyzing nutrition',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startStepProgress();
    _runGeminiAnalysis();
  }

  void _runGeminiAnalysis() async {
    try {
      final gemini = GeminiService();
      if (widget.imageBytes != null) {
        _analyzedMeal = await gemini.analyzeFood(imageBytes: widget.imageBytes!).timeout(
          const Duration(seconds: 25),
          onTimeout: () => gemini.generateSmartFallback(widget.imageBytes),
        );
      } else {
        // Fallback default sample analysis
        await Future.delayed(const Duration(milliseconds: 1500));
        _analyzedMeal = const MealLogItem(
          id: 'sample_meal',
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
      }
    } catch (_) {
      // Fallback
    } finally {
      _isGeminiDone = true;
      _checkCompletionAndNavigate();
    }
  }

  void _startStepProgress() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
        _checkCompletionAndNavigate();
      }
    });
  }

  void _checkCompletionAndNavigate() {
    if (_isGeminiDone && mounted) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep = _steps.length - 1;
        });
      }
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisResultScreen(
                customResult: _analyzedMeal,
                imageBytes: widget.imageBytes,
                imagePath: widget.imagePath,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 6),

              // Title
              const Text(
                'Analyzing your meal...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              // Circular Food Preview with Scanning Ring (Optimized size)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Rotating Animated Ring
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 146,
                        height: 146,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 6,
                          ),
                        ),
                      ),
                    ),

                    // Progress Ring
                    Container(
                      width: 138,
                      height: 138,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3.5,
                        ),
                      ),
                    ),

                    // Circular Food Image
                    Container(
                      width: 122,
                      height: 122,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildFoodImage(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Checklist Steps (Compact, elegant padding)
              Column(
                children: List.generate(_steps.length, (index) {
                  final isDone = index < _currentStep;
                  final isCurrent = index == _currentStep;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDone || isCurrent ? AppColors.surface : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDone
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox / Spinner
                        if (isDone)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 15, color: Colors.white),
                          )
                        else if (isCurrent)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.textMuted, width: 2),
                            ),
                          ),

                        const SizedBox(width: 12),

                        // Step Title
                        Text(
                          _steps[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isDone || isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              // AI Confidence Sparkline Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
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
                          'AI Confidence',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_analyzedMeal?.aiConfidence ?? 94}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Mini Sparkline Graph
                    Row(
                      children: [
                        _buildSparkBar(12, 0.4),
                        _buildSparkBar(18, 0.6),
                        _buildSparkBar(22, 0.8),
                        _buildSparkBar(28, 1.0),
                        _buildSparkBar(26, 0.94),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage() {
    if (widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
      );
    }
    if (widget.imagePath != null && !kIsWeb) {
      return Image.file(
        File(widget.imagePath!),
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=400&auto=format&fit=crop',
      fit: BoxFit.cover,
    );
  }

  Widget _buildSparkBar(double height, double opacity) {
    return Container(
      width: 5,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
