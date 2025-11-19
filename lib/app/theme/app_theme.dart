import 'package:flutter/material.dart';

class AppTheme {
  static const Color adwaitaBlue = Color(0xFF353535);
  static const Color adwaitaBackground = Color(0xFFf7f7f7);
  static const Color adwaitaHeaderBar = Color(0xFFf7f7f7);
  static const Color adwaitaTextColor = Color(0xFF353535);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      primaryColor: adwaitaBlue,
      scaffoldBackgroundColor: adwaitaBackground,

      colorScheme: const ColorScheme.light(
        primary: adwaitaBlue,
        surface: AppTheme.adwaitaBackground,
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

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.adwaitaBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    );
  }
}
