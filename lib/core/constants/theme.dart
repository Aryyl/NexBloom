import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Default Premium Indigo Seed
  static const _defaultSeedColor = Colors.indigo;
  static const _defaultPrimaryLight = Color(0xFF6366F1); // Indigo 500
  static const _defaultPrimaryDark = Color(0xFF818CF8); // Indigo 400

  // Custom Navy Colors for Dark Mode (Slate 900/800)
  static const _darkBackground = Color(0xFF0F172A); // Slate 900
  static const _darkSurface = Color(0xFF1E293B); // Slate 800

  static ThemeData lightTheme = _buildLightTheme();
  static ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildLightTheme({Color? primaryColor}) {
    final seed = primaryColor ?? _defaultSeedColor;
    final primary = primaryColor ?? _defaultPrimaryLight;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        primary: primary,
        secondary: const Color(0xFF14B8A6), // Teal 500
        surface: const Color(0xFFF8FAFC), // Slate 50
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: const Color(0xFF1E293B), // Slate 800
        displayColor: const Color(0xFF0F172A), // Slate 900
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1E293B),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData _buildDarkTheme({Color? primaryColor}) {
    final seed = primaryColor ?? _defaultSeedColor;
    final primary = primaryColor != null
        ? HSLColor.fromColor(primaryColor).withLightness(0.7).toColor()
        : _defaultPrimaryDark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        primary: primary,
        secondary: const Color(0xFF2DD4BF), // Teal 400
        surface: _darkBackground,
        onSurface: const Color(0xFFF1F5F9), // Slate 100
      ),
      scaffoldBackgroundColor: _darkBackground,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFF1F5F9), // Slate 100
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _darkBackground,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: _darkSurface,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shadowColor: Colors.black45,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        elevation: 0,
        backgroundColor: _darkBackground,
        indicatorColor: Color(0xFF334155), // Slate 700
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  /// Rebuild themes with a custom primary color
  static void applyPrimaryColor(Color? color) {
    lightTheme = _buildLightTheme(primaryColor: color);
    darkTheme = _buildDarkTheme(primaryColor: color);
  }
}
