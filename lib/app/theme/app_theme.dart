import 'package:flutter/material.dart';

class AppTheme {
  static const Color adwaitaBlue = Color(0xFF3584e4);
  static const Color adwaitaBackground = Color(0xFFfafafa);
  static const Color adwaitaHeaderBar = Color(0xFFebebeb);
  static const Color adwaitaTextColor = Color(0xFF2e3436);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      primaryColor: adwaitaBlue,
      scaffoldBackgroundColor: adwaitaBackground,

      colorScheme: const ColorScheme.light(
        primary: adwaitaBlue,
        surface: Colors.white,
        onSurface: adwaitaTextColor,
      ),

      fontFamily: 'Cantarell',

      appBarTheme: const AppBarTheme(
        backgroundColor: adwaitaHeaderBar,
        foregroundColor: adwaitaTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cantarell',
          fontWeight: FontWeight.bold,
          color: adwaitaTextColor,
          fontSize: 16,
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
