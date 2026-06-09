// lib/core/theme/theme_extensions.dart

import 'package:flutter/material.dart';
import 'colors.dart';

extension ThemeExtensions on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? ColorsManager.darkBackground : ColorsManager.white;

  Color get cardColor =>
      isDark ? ColorsManager.darkSurface : ColorsManager.white;

  Color get textPrimaryColor =>
      isDark ? ColorsManager.darkTextPrimary : ColorsManager.black;

  Color get textSecondaryColor =>
      isDark ? ColorsManager.darkTextSecondary : ColorsManager.darkGray;

  Color get dividerColor =>
      isDark ? ColorsManager.grey200 : ColorsManager.grey100;

  Color get surfaceColor =>
      isDark ? ColorsManager.darkSurface : ColorsManager.white;

  Color get iconColor => isDark ? ColorsManager.white : ColorsManager.black;

  Color get buttonPrimaryColor =>
      isDark ? ColorsManager.primary400 : ColorsManager.black;

  Color get stepperButtonColor =>
      isDark ? ColorsManager.primary400 : ColorsManager.primaryColor;

  Color get stepperButtonIconColor => ColorsManager.white;

  Color get handleColor =>
      isDark ? ColorsManager.darkTextSecondary : ColorsManager.black;

  Color get borderColor =>
      isDark ? ColorsManager.grey200 : ColorsManager.grey100;

  Color get inputFillColor =>
      isDark ? ColorsManager.darkSurface : ColorsManager.white;

  Color get shadowColor => isDark
      ? ColorsManager.black.withValues(alpha: 0.3)
      : ColorsManager.black.withValues(alpha: 0.1);
}
