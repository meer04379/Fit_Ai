import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Vibrant Nature Green)
  static const Color primary = Color(0xFF22C55E); // Emerald Green
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryAccent = Color(0xFF10B981);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF3F4F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFFFFFFFF);

  // Nutrition / Macro Colors
  static const Color caloriesAccent = Color(0xFF22C55E);
  static const Color protein = Color(0xFF3B82F6); // Blue
  static const Color carbs = Color(0xFF0EA5E9); // Sky / Teal
  static const Color fat = Color(0xFFF59E0B); // Amber / Orange

  // Status & Utility Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Dark/Scanner Mode
  static const Color scannerBackground = Color(0xFF000000);
  static const Color scannerOverlay = Color(0x80000000);
  static const Color scannerTarget = Color(0xFF22C55E);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
