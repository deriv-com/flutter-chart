import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Utility class for color-related operations.
class ColorUtils {
  /// Returns a list of theme-aware color presets.
  static List<Color> getThemeColors({required bool isDarkTheme}) {
    return [
      // Brand colors
      BrandColors.coral,
      BrandColors.greenish,
      BrandColors.orange,

      // Accent colors
      isDarkTheme ? DarkThemeColors.accentGreen : LightThemeColors.accentGreen,
      isDarkTheme ? DarkThemeColors.accentRed : LightThemeColors.accentRed,
      isDarkTheme
          ? DarkThemeColors.accentYellow
          : LightThemeColors.accentYellow,

      // Base colors
      isDarkTheme ? DarkThemeColors.base01 : LightThemeColors.base01,
      isDarkTheme ? DarkThemeColors.base04 : LightThemeColors.base04,
      isDarkTheme ? DarkThemeColors.base07 : LightThemeColors.base07,
    ];
  }

  /// Returns a list of positive color presets.
  static List<Color> getPositiveColors() {
    return [
      Colors.green,
      Colors.lightGreen,
      Colors.teal,
      Colors.cyan,
      DarkThemeColors.accentGreen,
      Colors.greenAccent,
    ];
  }

  /// Returns a list of negative color presets.
  static List<Color> getNegativeColors() {
    return [
      Colors.red,
      Colors.redAccent,
      Colors.deepOrange,
      Colors.pink,
      DarkThemeColors.accentRed,
      BrandColors.coral,
    ];
  }

  /// Returns a list of neutral color presets.
  static List<Color> getNeutralColors() {
    return [
      Colors.blue,
      Colors.blueGrey,
      Colors.purple,
      Colors.amber,
      Colors.orange,
      BrandColors.greenish,
    ];
  }

  /// Calculates the contrast ratio between two colors.
  ///
  /// The WCAG 2.0 contrast ratio is calculated as:
  /// (L1 + 0.05) / (L2 + 0.05), where L1 is the luminance of the lighter color
  /// and L2 is the luminance of the darker color.
  ///
  /// Returns a value between 1 and 21, where:
  /// - 1:1 means no contrast (same color)
  /// - 21:1 means maximum contrast (black on white)
  ///
  /// WCAG 2.0 recommends:
  /// - At least 4.5:1 for normal text
  /// - At least 3:1 for large text
  /// - At least 7:1 for enhanced contrast
  static double calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if the contrast ratio between two colors meets WCAG guidelines.
  ///
  /// Returns a map with the following keys:
  /// - 'normalText': Whether the contrast is sufficient for normal text (4.5:1)
  /// - 'largeText': Whether the contrast is sufficient for large text (3:1)
  /// - 'enhanced': Whether the contrast is sufficient for enhanced contrast (7:1)
  /// - 'ratio': The actual contrast ratio
  static Map<String, dynamic> checkContrast(
      Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);

    return {
      'normalText': ratio >= 4.5,
      'largeText': ratio >= 3.0,
      'enhanced': ratio >= 7.0,
      'ratio': ratio,
    };
  }

  /// Returns a color name based on its proximity to known colors.
  ///
  /// This is a simple implementation that matches to the closest named color
  /// in the Material Design palette.
  static String getColorName(Color color) {
    final Map<String, Color> namedColors = {
      'Red': Colors.red,
      'Pink': Colors.pink,
      'Purple': Colors.purple,
      'Deep Purple': Colors.deepPurple,
      'Indigo': Colors.indigo,
      'Blue': Colors.blue,
      'Light Blue': Colors.lightBlue,
      'Cyan': Colors.cyan,
      'Teal': Colors.teal,
      'Green': Colors.green,
      'Light Green': Colors.lightGreen,
      'Lime': Colors.lime,
      'Yellow': Colors.yellow,
      'Amber': Colors.amber,
      'Orange': Colors.orange,
      'Deep Orange': Colors.deepOrange,
      'Brown': Colors.brown,
      'Grey': Colors.grey,
      'Blue Grey': Colors.blueGrey,
      'Black': Colors.black,
      'White': Colors.white,
      'Coral': BrandColors.coral,
      'Greenish': BrandColors.greenish,
      'Brand Orange': BrandColors.orange,
    };

    String closestName = 'Custom';
    double closestDistance = double.infinity;

    namedColors.forEach((name, namedColor) {
      final distance = _calculateColorDistance(color, namedColor);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestName = name;
      }
    });

    // If the color is very close to a named color, return the name
    // Otherwise, return "Custom"
    return closestDistance < 30 ? closestName : 'Custom';
  }

  /// Calculates the Euclidean distance between two colors in RGB space.
  static double _calculateColorDistance(Color a, Color b) {
    final rDiff = (a.red - b.red).toDouble();
    final gDiff = (a.green - b.green).toDouble();
    final bDiff = (a.blue - b.blue).toDouble();

    return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
  }

  /// Simple square root implementation for color distance calculation.
  static double sqrt(double value) {
    return value <= 0 ? 0 : value.sqrt();
  }
}

/// Extension method for double to calculate square root.
extension DoubleExtension on double {
  /// Calculates the square root of a double value using Newton's method.
  ///
  /// Returns 0 for non-positive values.
  /// For positive values, uses an iterative approach to approximate the square root
  /// with a precision of 0.000001.
  double sqrt() {
    if (this <= 0) {
      return 0;
    }

    double x = this;
    double y = 1;
    const double e = 0.000001; // Precision

    while (x - y > e) {
      x = (x + y) / 2;
      y = this / x;
    }

    return x;
  }
}
