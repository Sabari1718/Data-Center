import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceColor =>
      isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get cardColor =>
      isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get borderColor =>
      isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get textPrimaryColor =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondaryColor =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textMutedColor =>
      isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
