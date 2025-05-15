import 'dart:math' show pi;
import 'design_token_utils.dart';

/// Abstract class for token value formatters (Strategy Pattern)
///
/// This class defines the interface for all token value formatters.
/// Each formatter implements this interface to handle specific token types
/// (colors, dimensions, etc.) and convert them to appropriate Dart code.
///
/// The Strategy Pattern allows for different formatting strategies to be
/// selected at runtime based on the token type, making the code more modular
/// and extensible.
abstract class DesignTokenValueFormatter {
  /// Formats a token value based on its type
  ///
  /// Parameters:
  /// - value: The raw token value to format (can be a string, number, map, etc.)
  /// - category: The token category (core, light, dark) to determine context
  ///
  /// Returns:
  /// A string representation of the token value formatted as Dart code
  String format(dynamic value, String category);
}

/// Formatter for color tokens
///
/// Handles various color formats including:
/// - Hex colors (#RRGGBB, #RGB)
/// - RGBA colors (rgba(r,g,b,a))
/// - Token references ({core.color.solid.red.500})
/// - Linear gradients (linear-gradient(...))
///
/// Converts these formats to appropriate Flutter Color objects or expressions.
class ColorTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return _formatColorValue(value.toString(), category);
  }

  /// Formats a color value to a Flutter Color
  ///
  /// Handles different color formats and converts them to appropriate Flutter
  /// Color objects or expressions. Supports hex colors, rgba values, token
  /// references, and linear gradients.
  ///
  /// Parameters:
  /// - value: The color value as a string
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A string representation of the color as Dart code
  String _formatColorValue(String value, String category) {
    if (value.startsWith('#')) {
      // Convert hex color to Color
      String hex = value.replaceAll('#', '');
      if (hex.length == 3) {
        // Convert shorthand hex to full hex
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 6) {
        // Add alpha channel if not present
        hex = 'FF$hex';
      }
      return 'Color(0x$hex)';
    } else if (value.startsWith('rgba')) {
      // Handle rgba values
      final match = DesignTokenUtils.rgbaPattern.firstMatch(value);

      if (match != null) {
        final int r = int.parse(match.group(1)!);
        final int g = int.parse(match.group(2)!);
        final int b = int.parse(match.group(3)!);
        final double a = double.parse(
                match.group(4)?.toString().replaceAll('%', '') ?? '0.0') *
            0.01;
        return 'Color.fromRGBO($r, $g, $b, $a)';
      }
      final String transformed = transformRgbaTokenString(value, category);
      return transformed;
    } else if (value.startsWith('{') && value.endsWith('}')) {
      // Extract the token reference (remove the curly braces)
      final String tokenRef = value.substring(1, value.length - 1);

      // Convert to camelCase using the existing convertToDartPropertyName function
      return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
    } else if (value.contains('linear-gradient')) {
      // Convert linear gradient string to LinearGradient object
      return convertGradientStringToDartObject(value, category);
    }
    return "'$value'";
  }

  /// Transforms an rgba token string to a Color.fromRGBO expression
  ///
  /// Parses rgba strings that contain token references and converts them to
  /// Color.fromRGBO expressions with the appropriate token references.
  ///
  /// For example:
  /// "rgba({core.color.solid.red.500},{core.opacity.500})" becomes
  /// "Color.fromRGBO(coreColorSolidRed500.red, coreColorSolidRed500.green, coreColorSolidRed500.blue, coreOpacity500)"
  ///
  /// Parameters:
  /// - input: The rgba string with token references
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A Color.fromRGBO expression as a string
  String transformRgbaTokenString(String input, String category) {
    final List<String> parts = DesignTokenUtils.splitRgbaString(input);

    if (parts.length >= 7 &&
        parts[0] == 'rgba(' &&
        parts[1] == '{' &&
        parts[3] == '}' &&
        parts[4] == '{' &&
        parts[6] == '}' &&
        parts[7] == ')') {
      // Extract the color and opacity token references
      final String colorToken =
          DesignTokenUtils.convertToDartPropertyName(parts[2], category);
      final String opacityToken =
          DesignTokenUtils.convertToDartPropertyName(parts[5], category);

      // Return a Color.fromRGBO expression directly
      return 'Color.fromRGBO($colorToken.red, $colorToken.green, $colorToken.blue, $opacityToken)';
    }

    final String originalInput = input;
    return originalInput;
  }

  /// Converts a gradient string to a Dart LinearGradient object
  ///
  /// Parses linear gradient strings and converts them to Flutter LinearGradient objects.
  /// Handles angle conversion, color stops, and token references within the gradient.
  ///
  /// For example:
  /// "linear-gradient(45deg, red 0%, blue 100%)" becomes
  /// "LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
  ///  transform: GradientRotation(...), colors: [Color(...), Color(...)], stops: [0.0, 1.0])"
  ///
  /// Parameters:
  /// - input: The linear gradient string
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A LinearGradient constructor expression as a string
  String convertGradientStringToDartObject(String input, String category) {
    final String originalInput = input;
    String cleanedInput = originalInput;

    // First, clean up the input if it's a full declaration
    if (cleanedInput.contains('=')) {
      // Extract just the gradient part
      final RegExp gradientPattern = RegExp(r"'(linear-gradient\([^']+\))'");
      final match = gradientPattern.firstMatch(cleanedInput);
      if (match != null) {
        cleanedInput = match.group(1)!;
      }
    }

    // Remove any surrounding quotes
    cleanedInput = cleanedInput.replaceAll('\'', '').replaceAll('"', '');

    // Format the token references
    final String formattedGradient =
        DesignTokenUtils.formatLinearGradientValue(cleanedInput, category);

    // Parse the angle and color stops
    final Match? angleMatch =
        DesignTokenUtils.linearGradientPattern.firstMatch(formattedGradient);

    if (angleMatch != null) {
      final String angleStr = angleMatch.group(1)!.trim();
      final String colorStopsStr = angleMatch.group(2)!.trim();

      // Convert angle to radians for Flutter's LinearGradient
      double angleInDegrees = 0;
      if (angleStr.endsWith('deg')) {
        angleInDegrees =
            double.tryParse(angleStr.substring(0, angleStr.length - 3)) ?? 0.0;
      }

      // Flutter's LinearGradient uses radians and a different coordinate system
      // Convert CSS angle to Flutter angle (CSS 0deg is bottom to top, Flutter 0 radians is left to right)
      final String angleInRadians = '${(angleInDegrees - 90) * pi / 180}';

      // Parse color stops
      final List<String> colorStops =
          colorStopsStr.split(',').map((s) => s.trim()).toList();
      final List<String> colors = [];
      final List<String> stops = [];

      for (final String colorStop in colorStops) {
        // Split the color and position
        final Match? colorStopMatch =
            DesignTokenUtils.colorStopPattern.firstMatch(colorStop);

        if (colorStopMatch != null) {
          final String color = colorStopMatch.group(1)!.trim();
          final String position = colorStopMatch.group(2)!.trim();

          // Convert percentage to fraction
          final double positionValue =
              double.tryParse(position.substring(0, position.length - 1)) ??
                  0.0;
          final double normalizedPosition = positionValue / 100;

          colors.add(color);
          stops.add(normalizedPosition.toString());
        } else {
          // Just a color without position
          colors.add(colorStop);
        }
      }

      // Build the LinearGradient
      final StringBuffer gradientBuilder = StringBuffer()
        ..write('LinearGradient(\n')
        ..write('    begin: Alignment.centerLeft,\n')
        ..write('    end: Alignment.centerRight,\n')
        ..write('    transform: GradientRotation($angleInRadians),\n')
        // Add colors
        ..write('    colors: [${colors.join(', ')}],\n');

      // Add stops if available
      if (stops.isNotEmpty && stops.length == colors.length) {
        gradientBuilder.write('    stops: [${stops.join(', ')}],\n');
      }

      gradientBuilder.write('  )');

      return gradientBuilder.toString();
    }

    // If we couldn't parse it, return the formatted string
    return '\'$formattedGradient\'';
  }
}

/// Formatter for numeric tokens (borderRadius, borderWidth, spacing, sizing)
class NumericTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return _formatNumericValue(value.toString(), category);
  }

  /// Formats a numeric value
  String _formatNumericValue(String value, String category) {
    // Check if the value is a token reference
    if (value.startsWith('{') && value.endsWith('}')) {
      // Extract the token reference (remove the curly braces)
      final String tokenRef = value.substring(1, value.length - 1);

      // Convert to camelCase using the existing convertToDartPropertyName function
      return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
    }

    final String originalValue = value;
    String cleanedValue = originalValue;

    if (cleanedValue.endsWith('px')) {
      cleanedValue = cleanedValue.substring(0, cleanedValue.length - 2);
    }
    final double? numValue = double.tryParse(cleanedValue);
    if (numValue != null) {
      return numValue.toString();
    }
    return "'$originalValue'";
  }
}

/// Formatter for percentage tokens (opacity)
class PercentageTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return _formatPercentageValue(value.toString(), category);
  }

  /// Formats a percentage value
  String _formatPercentageValue(String value, String category) {
    final String originalValue = value;

    if (originalValue.endsWith('%')) {
      final String numericPart =
          originalValue.substring(0, originalValue.length - 1);
      final double? numValue = double.tryParse(numericPart);
      if (numValue != null) {
        return (numValue / 100).toString();
      }
    }
    // Check if the value is a token reference
    if (originalValue.startsWith('{') && originalValue.endsWith('}')) {
      // Extract the token reference (remove the curly braces)
      final String tokenRef =
          originalValue.substring(1, originalValue.length - 1);

      // Convert to camelCase using the existing convertToDartPropertyName function
      return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
    }
    return originalValue;
  }
}

/// Formatter for box shadow tokens
class BoxShadowTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return _formatBoxShadowValue(value, category);
  }

  /// Formats a box shadow value
  String _formatBoxShadowValue(dynamic value, String category) {
    if (value is List) {
      final List<String> shadows = [];
      for (final shadow in value) {
        shadows.add(
            _formatSingleBoxShadow(shadow as Map<String, dynamic>, category));
      }
      return '[${shadows.join(', ')}]';
    } else if (value is Map) {
      return _formatSingleBoxShadow(value as Map<String, dynamic>, category);
    } else if (value is String &&
        value.startsWith('{') &&
        value.endsWith('}')) {
      // Extract the token reference (remove the curly braces)
      final String tokenRef = value.substring(1, value.length - 1);

      // Convert to camelCase using the existing convertToDartPropertyName function
      return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
    }
    return "'$value'";
  }

  /// Formats a single box shadow
  String _formatSingleBoxShadow(Map<String, dynamic> shadow, String category) {
    final numericFormatter = NumericTokenFormatter();
    final colorFormatter = ColorTokenFormatter();

    final x = numericFormatter.format(shadow['x'] ?? '0', category);
    final y = numericFormatter.format(shadow['y'] ?? '0', category);
    final blur = numericFormatter.format(shadow['blur'] ?? '0', category);
    final spread = numericFormatter.format(shadow['spread'] ?? '0', category);
    final color =
        shadow['color'] != null && shadow['color'].toString().isNotEmpty
            ? colorFormatter.format(shadow['color'], category)
            : 'Colors.transparent';

    return 'BoxShadow(color: $color, offset: Offset($x, $y), blurRadius: $blur, spreadRadius: $spread)';
  }
}

/// Formatter for font-related tokens (fontFamilies, fontWeights, textDecoration)
class FontTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    if (value is String && value.startsWith('{') && value.endsWith('}')) {
      // Extract the token reference (remove the curly braces)
      final String tokenRef = value.substring(1, value.length - 1);

      // Convert to camelCase using the existing convertToDartPropertyName function
      return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
    }
    return "'$value'";
  }
}

/// Formatter for duration tokens
class DurationTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return _formatDurationValue(value.toString());
  }

  /// Formats a duration value to a Flutter Duration
  String _formatDurationValue(String value) {
    // Remove any surrounding quotes
    final String cleanedValue = value.replaceAll('\'', '').replaceAll('"', '');

    // Check if the value ends with 'ms' (milliseconds)
    if (cleanedValue.endsWith('ms')) {
      // Extract the numeric part
      final String numericPart =
          cleanedValue.substring(0, cleanedValue.length - 2);
      final int? milliseconds = int.tryParse(numericPart);

      if (milliseconds != null) {
        return 'Duration(milliseconds: $milliseconds)';
      }
    }

    // If we couldn't parse it, return the original string
    return "'$cleanedValue'";
  }
}

/// Formatter for cubic-bezier tokens
class CubicBezierTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    return convertCubicBezierToDartObject(value.toString());
  }

  /// Converts a cubic-bezier string to a Dart Cubic object
  String convertCubicBezierToDartObject(String input) {
    // Remove any surrounding quotes
    final String cleanedInput = input.replaceAll('\'', '').replaceAll('"', '');

    // Pattern to match cubic-bezier values
    final Match? match =
        DesignTokenUtils.cubicBezierPattern.firstMatch(cleanedInput);

    if (match != null) {
      final double x1 = double.parse(match.group(1)!);
      final double y1 = double.parse(match.group(2)!);
      final double x2 = double.parse(match.group(3)!);
      final double y2 = double.parse(match.group(4)!);

      // Check for common curves
      if (x1 == 0.0 && y1 == 0.0 && x2 == 1.0 && y2 == 1.0) {
        return 'Curves.linear /* cubic-bezier(0.0, 0.0, 1.0, 1.0) - A linear animation curve */';
      } else if (x1 == 0.0 && y1 == 0.0 && x2 == 0.0 && y2 == 1.0) {
        return 'Curves.decelerate /* cubic-bezier(0.0, 0.0, 0.0, 1.0) - Animation curve that starts quickly and decelerates */';
      } else if (x1 == 0.42 && y1 == 0.0 && x2 == 1.0 && y2 == 1.0) {
        return 'Curves.ease /* cubic-bezier(0.42, 0.0, 1.0, 1.0) - Standard CSS ease curve */';
      } else if (x1 == 0.25 && y1 == 0.1 && x2 == 0.25 && y2 == 1.0) {
        return 'Curves.fastOutSlowIn /* cubic-bezier(0.25, 0.1, 0.25, 1.0) - Material Design standard curve */';
      } else if (x1 == 0.42 && y1 == 0.0 && x2 == 1.0 && y2 == 1.0) {
        return 'Curves.easeIn /* cubic-bezier(0.42, 0.0, 1.0, 1.0) - Animation curve that starts slowly and accelerates */';
      } else if (x1 == 0.0 && y1 == 0.0 && x2 == 0.58 && y2 == 1.0) {
        return 'Curves.easeOut /* cubic-bezier(0.0, 0.0, 0.58, 1.0) - Animation curve that starts quickly and decelerates */';
      } else if (x1 == 0.42 && y1 == 0.0 && x2 == 0.58 && y2 == 1.0) {
        return 'Curves.easeInOut /* cubic-bezier(0.42, 0.0, 0.58, 1.0) - Animation curve with smooth acceleration and deceleration */';
      } else if (x1 == 0.18 && y1 == 1.0 && x2 == 0.22 && y2 == 1.0) {
        return 'Curves.fastLinearToSlowEaseIn /* cubic-bezier(0.18, 1.0, 0.22, 1.0) - Animation curve that starts with linear motion and ends with a deceleration */';
      } else if (x1 == 0.15 && y1 == 0.85 && x2 == 0.85 && y2 == 0.15) {
        return 'Curves.slowMiddle /* cubic-bezier(0.15, 0.85, 0.85, 0.15) - Animation curve that is slow in the middle */';
      } else {
        // Create a custom Cubic
        return 'Cubic($x1, $y1, $x2, $y2)';
      }
    }

    // If we couldn't parse it, return the original string
    return "'$cleanedInput'";
  }
}

/// Factory for creating token formatters based on token type
class TokenFormatterFactory {
  static final Map<String, DesignTokenValueFormatter> _formatters = {
    'color': ColorTokenFormatter(),
    'borderRadius': NumericTokenFormatter(),
    'borderWidth': NumericTokenFormatter(),
    'spacing': NumericTokenFormatter(),
    'sizing': NumericTokenFormatter(),
    'opacity': PercentageTokenFormatter(),
    'fontSizes': NumericTokenFormatter(),
    'lineHeights': NumericTokenFormatter(),
    'paragraphSpacing': NumericTokenFormatter(),
    'fontFamilies': FontTokenFormatter(),
    'fontWeights': FontTokenFormatter(),
    'textDecoration': FontTokenFormatter(),
    'boxShadow': BoxShadowTokenFormatter(),
    'duration': DurationTokenFormatter(),
  };

  /// Get a formatter for the specified token type
  static DesignTokenValueFormatter getFormatter(String type) {
    return _formatters[type] ?? _DefaultTokenFormatter();
  }
}

/// Default formatter for token types that don't have a specific formatter
class _DefaultTokenFormatter implements DesignTokenValueFormatter {
  @override
  String format(dynamic value, String category) {
    if (value == null) {
      return 'null';
    }

    if (value is String) {
      // Handle references like {core.color.solid.slate.50}
      if (value.contains('rgba')) {
        return TokenFormatterFactory.getFormatter('color')
            .format(value, category);
      } else if (value.contains('linear-gradient')) {
        final colorFormatter = TokenFormatterFactory.getFormatter('color');
        // Convert linear gradient string to LinearGradient object
        return colorFormatter is ColorTokenFormatter
            ? colorFormatter.convertGradientStringToDartObject(value, category)
            : 'Invalid formatter';
      } else if (value.contains('cubic-bezier')) {
        // Convert cubic-bezier to Cubic object
        return TokenFormatterFactory.getFormatter('duration')
            .format(value, category);
      } else if (value.startsWith('{') && value.endsWith('}')) {
        // Extract the token reference (remove the curly braces)
        final String tokenRef = value.substring(1, value.length - 1);

        // Convert to camelCase using the existing convertToDartPropertyName function
        return DesignTokenUtils.convertToDartPropertyName(tokenRef, category);
      } else if (value.endsWith('ms')) {
        // Handle motion duration values
        return TokenFormatterFactory.getFormatter('duration')
            .format(value, category);
      }
      return "'$value'";
    } else {
      return value.toString();
    }
  }
}
