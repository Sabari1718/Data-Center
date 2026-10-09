import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primarySubtle = Color(0xFFEEF2FF); // Indigo 50
  static const Color primarySubtleDark = Color(0xFF1E1B4B); // Indigo 950

  static const Color secondary = Color(0xFF7C3AED); // Violet 600
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondarySubtle = Color(0xFFF5F3FF);

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successSubtle = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSubtle = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSubtle = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF0EA5E9); // Sky 500
  static const Color infoSubtle = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF0369A1);

  // Light Theme Neutrals
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color dividerLight = Color(0xFFEDF2F7);

  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Dark Theme Neutrals
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color cardDark = Color(0xFF182238);
  static const Color borderDark = Color(0xFF26334D);
  static const Color dividerDark = Color(0xFF1F2B42);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Accent Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF131B2E)],
  );
}
