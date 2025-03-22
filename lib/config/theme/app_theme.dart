import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xff692960);
  static ThemeData lightThme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    //colors
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: Color(0xff8E8E93),
      surface: Colors.white,
      onSurface: Colors.black,
      tertiary: Color(0xff7CBEC2),
      onPrimary: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryColor.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: primaryColor),
        ),
        hintStyle: TextStyle(
          color: Colors.grey[600],
        )),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
