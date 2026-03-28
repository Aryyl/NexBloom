import 'dart:ui';

class AppColors {
  // Modern 2026 Color Palette - Indigo & Teal
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF1E1B4B);

  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF134E4A);

  static const Color tertiary = Color(0xFFF59E0B); // Amber accent
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  static const Color background = Color(
    0xFFF3F4F6,
  ); // Cool Gray 100 - Higher contrast
  static const Color onBackground = Color(0xFF111827); // Cool Gray 900
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color textPrimary = onBackground; // Alias for compatibility

  // Surface variations for hierarchy
  static const Color surfaceContainerLow = Color(0xFFF9FAFB);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);

  // Outline for borders
  static const Color outline = Color(0xFFE5E7EB); // Cool Gray 200
  static const Color outlineVariant = Color(0xFFD1D5DB); // Cool Gray 300

  // Success color
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Gradient colors for modern effects
  static const Color gradientStart = Color(0xFF6366F1);
  static const Color gradientEnd = Color(0xFF14B8A6);

  // Custom subject colors - softer palette
  static const List<Color> subjectColors = [
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFFA855F7), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFFEC4899), // Pink
  ];
}
