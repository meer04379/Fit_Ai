import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../core/constants/app_colors.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percent; // 0.0 to 1.0
  final int percentageText;
  final String subText;
  final double radius;
  final double lineWidth;
  final Color progressColor;
  final Color backgroundColor;

  const CircularProgressWidget({
    super.key,
    required this.percent,
    required this.percentageText,
    this.subText = 'remaining',
    this.radius = 42.0,
    this.lineWidth = 8.0,
    this.progressColor = AppColors.primary,
    this.backgroundColor = const Color(0xFFDCFCE7),
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      animation: true,
      animationDuration: 1000,
      percent: percent.clamp(0.0, 1.0),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percentageText%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          if (subText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subText,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
