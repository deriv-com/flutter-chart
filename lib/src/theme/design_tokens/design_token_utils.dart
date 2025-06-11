/// Utility class for design token processing
///
/// This class provides utility functions and constants for processing design tokens.
/// It includes path constants, regex patterns, and helper methods for token name conversion,
/// string manipulation, and token formatting.
///
/// The utilities in this class are used throughout the token generation process
/// to ensure consistent handling of token references, paths, and formatting.
class DesignTokenUtils {
  /// Private constructor to prevent instantiation
  DesignTokenUtils._();

  /// Constants for token categories

  /// Core token category identifier
  static const String categoryCore = 'core';

  /// Light theme token category identifier
  static const String categoryLight = 'light';

  /// Dark theme token category identifier
  static const String categoryDark = 'dark';

  /// Component token category identifier
  static const String categoryComponent = 'component';

  /// File paths

  /// Path to the JSON file containing design tokens
  static const String tokensJsonPath =
      'lib/src/theme/design_tokens/tokens.json';

  /// Path to the generated Dart file for core tokens
  static const String coreDesignTokensPath =
      'lib/src/theme/design_tokens/core_design_tokens.dart';

  /// Path to the generated Dart file for light theme tokens
  static const String lightThemeDesignTokensPath =
      'lib/src/theme/design_tokens/light_theme_design_tokens.dart';

  /// Path to the generated Dart file for dark theme tokens
  static const String darkThemeDesignTokensPath =
      'lib/src/theme/design_tokens/dark_theme_design_tokens.dart';

  /// Path to the generated Dart file for component tokens
  static const String componentDesignTokensPath =
      'lib/src/theme/design_tokens/component_design_tokens.dart';

  /// Path to the token configuration file
  static const String configPath =
      'lib/src/theme/design_tokens/design_token_config.json';

  /// Pre-compiled regex patterns

  /// Pattern to match token references in curly braces, e.g. {core.color.red}
  static final RegExp tokenPattern = RegExp(r'\{([^{}]+)\}');

  /// Pattern to match RGBA color values, e.g. rgba(255, 0, 0, 0.5)
  static final RegExp rgbaPattern =
      RegExp(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+%?)\s*\)');

  /// Pattern to match cubic bezier values, e.g. cubic-bezier(0.42, 0, 1, 1)
  static final RegExp cubicBezierPattern = RegExp(
      r'cubic-bezier\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)');

  /// Pattern to match linear gradient values, e.g. linear-gradient(45deg, red, blue)
  static final RegExp linearGradientPattern =
      RegExp(r'linear-gradient\(([^,]+),(.+)\)');

  /// Pattern to match color stops in gradients, e.g. red 10%
  static final RegExp colorStopPattern = RegExp(r'(.+)\s+([0-9.]+%)');

  /// Converts dot notation token references to camelCase Dart property names
  ///
  /// This function transforms token references from dot notation (e.g., "core.color.red.500")
  /// to camelCase Dart property names (e.g., "coreColorRed500"). For non-core categories
  /// (light, dark), it also adds the "CoreDesignTokens." prefix to core token references.
  ///
  /// The function handles special cases like numeric parts in token names and
  /// different token categories (core, light, dark).
  ///
  /// Examples:
  /// - "core.color.red.500" in core category → "coreColorRed500"
  /// - "core.color.red.500" in light category → "CoreDesignTokens.coreColorRed500"
  /// - "light.background.primary" in light category → "backgroundPrimary"
  ///
  /// Parameters:
  /// - dotNotation: The token reference in dot notation
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A camelCase Dart property name with optional CoreDesignTokens prefix
  static String convertToDartPropertyName(String dotNotation, String category) {
    // Split by dots
    final parts = dotNotation.split('.');

    // Check if this is a core token reference
    final bool isCoreToken = parts.isNotEmpty && parts[0] == 'core';

    // For non-core categories (light, dark, etc.), prepend CoreDesignTokens to core token references
    if (isCoreToken && category != categoryCore) {
      // Start with CoreDesignTokens prefix
      const String result = 'CoreDesignTokens.';

      // Include "core" prefix and then add the rest of the parts
      String tokenName = 'core';
      for (int i = 1; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          // Capitalize first letter of each part after "core"
          // Handle numeric parts (like "730" in "core.elevation.shadow.730")
          if (parts[i].isNotEmpty && RegExp(r'^[0-9]').hasMatch(parts[i][0])) {
            // If the part starts with a number, don't capitalize it
            tokenName += parts[i];
          } else {
            // Otherwise capitalize the first letter using the extension
            tokenName += parts[i].capitalize();
          }
        }
      }

      return result + tokenName;
    } else {
      // For core category or non-core token references, use standard camelCase
      // Skip the first part if it's the category name (core, light, dark, component)
      int startIndex = 0;
      final bool isCoreToken = parts.isNotEmpty && parts[0] == categoryCore;
      if (parts.isNotEmpty &&
          (parts[0] == categoryCore ||
              parts[0] == categoryLight ||
              parts[0] == categoryDark ||
              parts[0] == categoryComponent)) {
        startIndex = 1;
      }

      // For core tokens in core category, add 'core' prefix
      final String prefix =
          (category == categoryCore && isCoreToken) ? 'core' : '';
      final StringBuffer result = StringBuffer(prefix);

      // Add first part after prefix
      if (startIndex < parts.length) {
        // If we have a prefix and it's not empty, capitalize the first part
        if (prefix.isNotEmpty) {
          // Capitalize the first letter of the first part after prefix
          result.write(parts[startIndex].capitalize());
        } else {
          // No prefix, first part stays lowercase
          result.write(parts[startIndex]);
        }
      }
      // Convert remaining parts to camelCase
      for (int i = startIndex + 1; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          // Handle numeric parts (like "730" in "core.elevation.shadow.730")
          if (RegExp(r'^[0-9]').hasMatch(parts[i][0])) {
            // If the part starts with a number, don't capitalize it
            result.write(parts[i]);
          } else {
            // Otherwise capitalize the first letter using the extension
            result.write(parts[i].capitalize());
          }
        }
      }

      return result.toString();
    }
  }

  /// Splits an rgba string into its components for parsing
  ///
  /// This function parses rgba strings that may contain token references in curly braces.
  /// It handles nested structures and returns a list of components that can be processed
  /// individually.
  ///
  /// For example, "rgba({core.color.red.500}, {core.opacity.500})" would be split into:
  /// ["rgba(", "{", "core.color.red.500", "}", "{", "core.opacity.500", "}", ")"]
  ///
  /// Parameters:
  /// - input: The rgba string to split
  ///
  /// Returns:
  /// A list of string components from the rgba expression
  static List<String> splitRgbaString(String input) {
    final List<String> result = [];

    // Return empty list for null or empty input
    if (input.isEmpty) {
      return result;
    }

    // Find the opening 'rgba('
    int index = 0;
    final int startIndex = input.indexOf('rgba(');

    if (startIndex != -1) {
      // Add 'rgba(' to the result
      result.add(input.substring(startIndex, startIndex + 5));
      index = startIndex + 5;

      // Process the rest of the string
      int depth = 0;
      int tokenStart = index;

      for (int i = index; i < input.length; i++) {
        final String char = input[i];

        if (char == '{') {
          if (depth == 0) {
            // If we're at depth 0 and find an opening brace,
            // add any text before it to the result (except whitespace and commas)
            if (i > tokenStart) {
              final String text = input.substring(tokenStart, i).trim();
              if (text.isNotEmpty && text != ',') {
                result.add(text);
              }
            }
            // Add the opening brace
            result.add('{');
            tokenStart = i + 1;
          }
          depth++;
        } else if (char == '}') {
          depth--;
          if (depth == 0) {
            // If we're back at depth 0, add the content inside the braces
            if (i > tokenStart) {
              result.add(input.substring(tokenStart, i));
            }
            // Add the closing brace
            result.add('}');
            tokenStart = i + 1;
          }
        } else if (char == ',' && depth == 0) {
          // Handle commas at depth 0
          if (i > tokenStart) {
            final String text = input.substring(tokenStart, i).trim();
            if (text.isNotEmpty) {
              result.add(text);
            }
          }
          tokenStart = i + 1;
        } else if (char == ')' && depth == 0) {
          // If we find a closing parenthesis at depth 0, we're at the end
          if (i > tokenStart) {
            final String text = input.substring(tokenStart, i).trim();
            if (text.isNotEmpty) {
              result.add(text);
            }
          }
          result.add(')');
          break;
        }
      }
    }

    return result;
  }

  /// Formats a linear gradient value by replacing token references with their camelCase versions
  ///
  /// This function processes linear gradient strings and replaces token references in
  /// curly braces with their camelCase Dart property name equivalents.
  ///
  /// For example:
  /// "linear-gradient(45deg, {core.color.red.500} 0%, {core.color.blue.500} 100%)"
  /// becomes
  /// "linear-gradient(45deg, coreColorRed500 0%, coreColorBlue500 100%)"
  ///
  /// Parameters:
  /// - value: The linear gradient string with token references
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A formatted linear gradient string with token references replaced by camelCase names
  static String formatLinearGradientValue(String value, String category) {
    // Remove any surrounding quotes
    final String cleanValue = value.replaceAll("'", '').replaceAll('"', '');

    // Replace each token reference with its camelCase version
    final String formattedValue =
        cleanValue.replaceAllMapped(tokenPattern, (match) {
      final String tokenRef = match.group(1)!;

      // Check if the token is already in camelCase format
      if (!tokenRef.contains('.')) {
        return tokenRef; // Already in camelCase, just remove the braces
      }

      // Convert from dot notation to camelCase
      final String camelCaseToken =
          convertToDartPropertyName(tokenRef, category);
      return camelCaseToken;
    });

    return formattedValue;
  }

  /// Determines if a token is a component token
  ///
  /// This function checks if the token key is "component" and the path is empty,
  /// or if the first element in the path is "component".
  ///
  /// Parameters:
  /// - paths: The token path as a list of string segments
  /// - key: The token key
  ///
  /// Returns:
  /// true if the token is a component token, false otherwise
  static bool isComponentToken(List<String> paths, String key) {
    return (paths.isEmpty && key.toLowerCase() == 'component') ||
        (paths.isNotEmpty && paths[0].toLowerCase() == 'component');
  }

  /// Determines if a token is a structural token
  ///
  /// This function checks if the token type is one of the predefined structural token types:
  /// typography, borderRadius, sizing, spacing, borderWidth, or boxShadow.
  /// Structural tokens typically define the fundamental visual properties of the design system.
  ///
  /// Parameters:
  /// - tokenType: The type of token to check
  ///
  /// Returns:
  /// true if the token is a structural token, false otherwise
  static bool isStructuralToken(String tokenType) {
    const structuralTokenTypes = [
      'typography',
      'borderRadius',
      'sizing',
      'spacing',
      'borderWidth',
      'boxShadow'
    ];
    return structuralTokenTypes.contains(tokenType);
  }

  /// Shared utility for formatting token references
  ///
  /// This method handles the common pattern of token references that are
  /// wrapped in curly braces (e.g., "{core.color.solid.red.500}").
  /// It extracts the token reference and converts it to a Dart property name.
  ///
  /// Parameters:
  /// - value: The value to check and potentially format as a token reference
  /// - category: The token category (core, light, dark) to determine context
  ///
  /// Returns:
  /// The formatted token reference if the value is a token reference,
  /// otherwise returns the original value as a string literal
  static String formatTokenReference(dynamic value, String category) {
    if (value is String && value.startsWith('{') && value.endsWith('}')) {
      final String tokenRef = value.substring(1, value.length - 1);
      return convertToDartPropertyName(tokenRef, category);
    }
    return "'$value'";
  }

  /// The standard header comment for design token class files.
  ///
  /// This header comment includes information about the file being generated automatically
  /// and should not be modified by hand. It also includes references to the source
  /// of the tokens and the repository where they are maintained.
  static String get designTokenFileHeaderComment {
    return '''
/// Generated code - do not modify by hand. Generated from tokens.json using the lib/src/theme/design_tokens/design_token_parser.dart script
/// The tokens.json file is generated from Figma tokens and can be found in the design tokens repository.
/// Design Tokens Repository: https://github.com/deriv-com/quill-tokens/blob/master/data/tokens.json

''';
  }
}

/// Extension method to capitalize the first letter of a string.
///
/// This utility extension is used throughout the token generation process
/// to ensure consistent capitalization of token names and paths.
///
extension StringExtension on String {
  /// Capitalizes the first letter of a string if it doesn't start with a number
  ///
  /// This helper method is used to handle token name parts during conversion.
  /// If the string is empty, it returns the empty string.
  /// If the string starts with a number, it returns it unchanged.
  /// Otherwise, it capitalizes the first letter.
  ///
  /// Returns:
  /// The processed string with first letter capitalized if applicable
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    // If the part starts with a number, don't capitalize it
    if (RegExp(r'^[0-9]').hasMatch(this[0])) {
      return this;
    }
    // Otherwise capitalize the first letter using the extension
    return isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  }
}
