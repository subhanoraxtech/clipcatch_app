import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF2563EB); // Modern vibrant blue
  static const Color accentColor = Color(0xFFF59E0B); // Amber for premium highlights
  
  // Light Mode Colors - Refined Slate/Zinc palette
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF0F172A); 
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode Colors - Deep Charcoal/Navy palette
  static const Color backgroundDark = Color(0xFF020617); // Deeper slate
  static const Color surfaceDark = Color(0xFF0F172A); 
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF1E293B);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceLight,
      onSurface: textLight,
      outline: borderLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textLight),
      titleTextStyle: TextStyle(
        color: textLight, 
        fontSize: 18, 
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.w800, letterSpacing: -1),
      headlineMedium: TextStyle(color: textLight, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      bodyLarge: TextStyle(color: textLight, fontSize: 16),
      bodyMedium: TextStyle(color: textLight, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: textMutedLight, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        minimumSize: const Size.fromHeight(58),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderLight),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textMutedLight,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceDark,
      onSurface: textDark,
      outline: borderDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark, 
        fontSize: 18, 
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textDark, fontWeight: FontWeight.w800, letterSpacing: -1),
      headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      bodyLarge: TextStyle(color: textDark, fontSize: 16),
      bodyMedium: TextStyle(color: textDark, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      hintStyle: const TextStyle(color: textMutedDark, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        minimumSize: const Size.fromHeight(58),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderDark),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: textMutedDark,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
