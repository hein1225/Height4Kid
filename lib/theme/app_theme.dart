import 'package:flutter/material.dart';

class AppTheme {
  static const Color pinkPrimary = Color(0xFFFF9A9E);
  static const Color pinkSecondary = Color(0xFFFECFEF);
  static const Color pinkBg = Color(0xFFFFF0F5);
  static const Color pinkHeroGradientStart = Color(0xFFFFE4E8);
  static const Color pinkHeroGradientEnd = Color(0xFFFFF0F5);
  static const Color pinkGroundStart = Color(0xFFFFE4E8);
  static const Color pinkGroundMid = Color(0xFFFFD4D9);
  static const Color pinkGroundEnd = Color(0xFFFFC9CF);

  static const Color bluePrimary = Color(0xFF74B9FF);
  static const Color blueSecondary = Color(0xFFA8D8FF);
  static const Color blueBg = Color(0xFFF0F8FF);
  static const Color blueHeroGradientStart = Color(0xFFE3F2FD);
  static const Color blueHeroGradientEnd = Color(0xFFF0F8FF);
  static const Color blueGroundStart = Color(0xFFE1F5FE);
  static const Color blueGroundMid = Color(0xFFBBDEFB);
  static const Color blueGroundEnd = Color(0xFF90CAF9);

  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color white = Color(0xFFFFFFFF);
  static const Color weightColor = Color(0xFFAED581);
  static const Color weightValueColor = Color(0xFF7CB342);

  static const Color chartGrid = Color(0xFFE8E8E8);
  static const Color chartGridDashed = Color(0xFFE0E0E0);
  static const Color chartYLabel = Color(0xFFB0B0B0);
  static const Color chartXLabel = Color(0xFFB0B0B0);
  static const Color highlightPoint = Color(0xFFFFD54F);

  static const Color navBg = Color(0xFFF8F8F8);
  static const Color formBorder = Color(0xFFF0F0F0);
  static const Color formBg = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF5F5F5);

  // 通用颜色别名
  static const Color textPrimary = textDark;
  static const Color primary = pinkPrimary;

  static ThemeData pinkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: pinkPrimary,
      primary: pinkPrimary,
      secondary: pinkSecondary,
      surface: white,
      onPrimary: white,
      onSurface: textDark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: pinkBg,
    fontFamily: 'Noto Sans SC',
  );

  static ThemeData blueTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: bluePrimary,
      primary: bluePrimary,
      secondary: blueSecondary,
      surface: white,
      onPrimary: white,
      onSurface: textDark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: blueBg,
    fontFamily: 'Noto Sans SC',
  );
}
