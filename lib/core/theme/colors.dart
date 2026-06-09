import 'package:flutter/material.dart';

class ColorsManager {
  // Primary Palette (Based on #005461)
  static const Color primaryColor = Color(0xFF005461);
  static const Color primary100 = Color(0xFFD0E4E7);
  static const Color primary200 = Color(0xFFA1C9CF);
  static const Color primary300 = Color(0xFF71ADB6);
  static const Color primary400 = Color(0xFF42929E);
  static const Color primary500 = Color(0xFF005461);

  // Secondary Palette (Golden/Yellow for contrast)
  static const Color secondary = Color(0xFFFFC933);
  static const Color secondary100 = Color(0xFFFFF4D6);
  static const Color secondary200 = Color(0xFFFFE499);
  static const Color secondary500 = Color(0xFFF7B600);
  static const Color secondary600 = Color(0xFFCC9600);
  static const Color secondary900 = Color(0xFF332500);

  // Neutral & Grays
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF0F0F0);
  static const Color grey200 = Color(0xFFCBCBCB);
  static const Color darkGray = Color(0xFF5F5F5F);
  static const Color darkGray400 = Color(0xFF666666);
  static const Color dark500 = Color(0xFF5F5F5F);
  static const Color darkFontColor = Color(0xFF1D1F1F);

  // Semantic Colors
  static const Color teal = Color(0xFF0A9A8F);
  static const Color lightTeal = Color(0xFFD2FFFC);
  static const Color errorColor = Color(0xFFCA4146);
  static const Color success500 = Color(0xFF00BF6F);
  static const Color transparent = Color(0x00FFFFFF);

  // Common Semantic Mapping
  static const Color red = Color(0xFFCA4146);
  static const Color green = Color(0xFF00BF6F);
  static const Color blue = Color(0xFF2196F3);
  static const Color orange = Color(0xFFF7B600);
  static const Color yellow = Color(0xFFFFC933);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color purple = Color(0xFF9C27B0);

  // Dark Mode Support
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}

extension ColorToMaterial on Color {
  MaterialColor toMaterialColor() {
    final Map<int, Color> swatch = {
      50: withOpacity(0.1),
      100: withOpacity(0.2),
      200: withOpacity(0.3),
      300: withOpacity(0.4),
      400: withOpacity(0.5),
      500: withOpacity(0.6),
      600: withOpacity(0.7),
      700: withOpacity(0.8),
      800: withOpacity(0.9),
      900: withOpacity(1.0),
    };
    return MaterialColor(value, swatch);
  }
}
