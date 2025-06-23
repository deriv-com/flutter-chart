/// Design Token Generators
///
/// This file contains the implementation of design token generators that transform
/// raw design tokens from a JSON structure into Dart code. The generators create
/// strongly-typed Dart classes that provide type-safe access to design tokens.
///
/// The implementation uses several design patterns:
/// - Factory Pattern: To create appropriate token generators based on token category
/// - Strategy Pattern: To format token values based on their type
/// - Template Method Pattern: Base class defines the algorithm structure, subclasses implement specific steps
///
/// The token generation process:
/// 1. Parse raw tokens from JSON
/// 2. Select appropriate generator based on token category (core, light, dark)
/// 3. Process tokens recursively, transforming them into Dart code
/// 4. Format token values based on their type (color, dimension, etc.)
/// 5. Write generated code to output files
///
/// This approach allows for consistent token generation while accommodating
/// different token categories and formatting requirements.

import 'dart:io';
import 'design_token_utils.dart';
import 'design_token_formatters.dart';
import 'design_token_logger.dart';

/// Custom Color class implementation to avoid direct Flutter dependency
/// This allows the token generator to work without requiring Flutter as a dependency
/// while still providing color functionality for token processing.
class Color {
  /// Creates a new Color with the given 32-bit value.
  ///
  /// The value is a 32-bit integer with the following format:
  /// - Bits 24-31: Alpha channel (opacity)
  /// - Bits 16-23: Red channel
  /// - Bits 8-15: Green channel
  /// - Bits 0-7: Blue channel
  const Color(this.value);

  /// Creates a color from red, green, blue, and opacity components.
  ///
  /// Each RGB component ranges from 0 to 255, and opacity ranges from 0.0 to 1.0.
  /// This constructor is compatible with Flutter's Color.fromRGBO constructor.
  Color.fromRGBO(int r, int g, int b, double opacity)
      : value = ((opacity * 0xff).round() << 24) | (r << 16) | (g << 8) | b;

  /// The underlying 32-bit ARGB color value.
  final int value;

  /// The red channel value, from 0 to 255.
  int get red => (value >> 16) & 0xFF;

  /// The green channel value, from 0 to 255.
  int get green => (value >> 8) & 0xFF;

  /// The blue channel value, from 0 to 255.
  int get blue => value & 0xFF;
}

/// Abstract class defining the interface for all design token generators.
///
/// This class is part of the Factory Pattern implementation, providing a common
/// interface for different token generator implementations. Each generator is
/// responsible for transforming raw design tokens into Dart code for a specific
/// token category (core, light, dark).
///
abstract class DesignTokenGenerator {
  /// Generate token class file
  String generate(Map<String, dynamic> tokens, List<String> tokenNames);

  /// Write tokens to file
  void writeToFile(String content, String filePath);

  /// Process tokens and add them to the output
  ///
  /// This method recursively processes tokens from a section of the token hierarchy,
  /// formats them based on their type, and adds them to the output StringBuffer.
  /// It handles both leaf tokens (with values) and nested token groups.
  ///
  /// Parameters:
  /// - output: The StringBuffer to write the generated code to
  /// - section: The current section of tokens to process
  /// - paths: The current path in the token hierarchy
  /// - category: The token category (core, light, dark)
  /// - tokenValues: Map to track processed tokens and avoid duplicates
  void processTokens(
      {required StringBuffer output,
      required Map<String, dynamic> section,
      required List<String> paths,
      required String category,
      required Map<String, String> tokenValues});
}

/// Base implementation for design token generators that provides common functionality.
///
/// This abstract class implements the DesignTokenGenerator interface and provides
/// shared functionality for all token generators. It follows the Template Method
/// pattern by defining the overall algorithm structure while allowing subclasses
/// to implement specific steps.
///
/// The class handles:
/// - Token processing and transformation
/// - File output generation
/// - Token value formatting
/// - Handling nested token structures
///
abstract class BaseDesignTokenGenerator implements DesignTokenGenerator {
  /// Creates a new BaseDesignTokenGenerator with the specified class name and category.
  ///
  /// This constructor initializes a new token generator with the specified class name
  /// and category. It also initializes an empty tokenValues map to track processed tokens.
  ///
  /// Parameters:
  /// - className: The name of the class to generate (e.g., CoreDesignTokens)
  /// - category: The token category (core, light, dark) that determines how tokens are processed
  BaseDesignTokenGenerator(this.className, this.category);

  /// The name of the class to generate
  final String className;

  /// The token category (core, light, dark)
  final String category;

  /// Map to track processed tokens and avoid duplicates
  final Map<String, String> tokenValues = {};

  @override

  /// Writes the generated token content to a file
  ///
  /// This method creates or overwrites a file at the specified path with the
  /// generated token content. It ensures the file is clean by deleting it first
  /// if it already exists.
  ///
  /// Parameters:
  /// - content: The generated Dart code content to write
  /// - filePath: The path where the file should be written
  void writeToFile(String content, String filePath) {
    final file = File(filePath);
    // Delete the file if it already exists to ensure clean output
    if (file.existsSync()) {
      file.deleteSync();
    }
    // Write the generated content to the file
    file.writeAsStringSync(content);
    DesignTokenLogger.info('Generated $filePath successfully.');
  }

  @override
  void processTokens(
      {required StringBuffer output,
      required Map<String, dynamic> section,
      required List<String> paths,
      required String category,
      required Map<String, String> tokenValues}) {
    section.forEach((key, value) {
      if (value is Map) {
        if (value.containsKey('value')) {
          // This is a leaf token with a value
          _processValueToken(output, key, value.cast<String, dynamic>(), paths,
              category, tokenValues);
        } else {
          // This is a nested token group
          _processNestedToken(output, key, value.cast<String, dynamic>(), paths,
              category, tokenValues);
        }
      }
    });
  }

  /// Processes a token that has a direct value.
  ///
  /// This method handles leaf tokens in the token hierarchy that contain actual values.
  /// It formats the token value based on its type, generates appropriate documentation,
  /// and adds the token to the output.
  ///
  /// Parameters:
  /// - output: The StringBuffer to write the generated code to
  /// - key: The token key (name)
  /// - value: The token value and metadata
  /// - paths: The current path in the token hierarchy
  /// - category: The token category (core, light, dark)
  /// - tokenValues: Map to track processed tokens and avoid duplicates
  ///
  void _processValueToken(
      StringBuffer output,
      String key,
      Map<String, dynamic> value,
      List<String> paths,
      String category,
      Map<String, String> tokenValues) {
    // Cast the map to the correct type
    final Map<String, dynamic> typedValue = value.cast<String, dynamic>();

    // Safely handle first character access
    final String firstChar = key.isNotEmpty ? key[0] : '';
    final String capitalizedKey = key.isNotEmpty
        ? key.replaceFirst(firstChar, firstChar.toUpperCase())
        : key;

    final String tokenName = '${paths.join()}$capitalizedKey';

    // Check if this token name has already been generated
    if (!tokenValues.containsKey(tokenName)) {
      final String tokenValue = _formatTokenValue(typedValue['value'],
          typedValue['type']?.toString() ?? 'default', category);
      final String description = typedValue.containsKey('description') &&
              typedValue['description'] != null
          ? '/// ${typedValue['description']}'
          : '';

      // Store the token value
      tokenValues[tokenName] = tokenValue;

      // Write to output with proper Dart documentation comment
      String commentText;
      if (description.isNotEmpty) {
        // If there's a description, use it and add the token value
        commentText = '$description (Value: ${typedValue['value']})';
      } else {
        // Generate a comment with just the token value
        commentText = '/// $tokenName with value: ${typedValue['value']}';
      }

      // Write the comment and then the token declaration
      output
        ..write('  $commentText\n')
        ..write('  static final $tokenName = $tokenValue;\n\n');
    } else {
      DesignTokenLogger.warning(
          'Duplicate token name detected in $category: $tokenName');
    }
  }

  /// Processes a nested token group.
  ///
  /// This method handles non-leaf nodes in the token hierarchy that contain
  /// other tokens rather than direct values. It builds the path for nested tokens
  /// and recursively processes them.
  ///
  /// Parameters:
  /// - output: The StringBuffer to write the generated code to
  /// - key: The token group key (name)
  /// - value: The nested token map
  /// - paths: The current path in the token hierarchy
  /// - category: The token category (core, light, dark)
  /// - tokenValues: Map to track processed tokens and avoid duplicates
  ///
  void _processNestedToken(
      StringBuffer output,
      String key,
      Map<String, dynamic> value,
      List<String> paths,
      String category,
      Map<String, String> tokenValues) {
    final newPaths = List<String>.from(paths);
    if (newPaths.isEmpty) {
      newPaths.add(key);
    } else {
      // Safely handle first character access
      final String firstChar = key.isNotEmpty ? key[0] : '';
      final String capitalizedKey = key.isNotEmpty
          ? key.replaceFirst(firstChar, firstChar.toUpperCase())
          : key;

      newPaths.add(capitalizedKey);
    }
    processTokens(
        output: output,
        section: value.cast<String, dynamic>(),
        paths: newPaths,
        category: category,
        tokenValues: tokenValues);
  }

  /// Formats a token value based on its type using the Strategy Pattern.
  ///
  /// This method delegates the formatting of token values to specialized formatters
  /// based on the token type (color, dimension, etc.). It uses the TokenFormatterFactory
  /// to get the appropriate formatter for each token type.
  ///
  /// Parameters:
  /// - value: The raw token value to format
  /// - type: The token type (color, dimension, etc.)
  /// - category: The token category (core, light, dark)
  ///
  /// Returns:
  /// A string representation of the token value formatted as Dart code
  ///
  String _formatTokenValue(dynamic value, String type, String category) {
    if (value == null) {
      return 'null';
    }

    // Use the TokenFormatterFactory to get the appropriate formatter
    return TokenFormatterFactory.getFormatter(type).format(value, category);
  }
}

/// Generator for core design tokens.
///
/// Core tokens are shared between light and dark themes and include foundational
/// design elements like typography, spacing, and other theme-independent values.
/// This generator creates a CoreDesignTokens class with static members for each token.
///
class CoreDesignTokenGenerator extends BaseDesignTokenGenerator {
  /// Creates a new CoreDesignTokenGenerator.
  ///
  /// This generator is specifically for core tokens that are shared between
  /// light and dark themes.
  CoreDesignTokenGenerator()
      : super('CoreDesignTokens', DesignTokenUtils.categoryCore);

  @override
  String generate(Map<String, dynamic> tokens, List<String> tokenNames) {
    final StringBuffer output = StringBuffer()
      ..write(DesignTokenUtils.designTokenFileHeaderComment)
      ..write('import \'package:flutter/material.dart\';\n\n')
      ..write('/// Core tokens that are shared between light and dark themes\n')
      ..write('class $className {\n')
      ..write('  $className._();\n\n');

    // Process core tokens
    DesignTokenLogger.info('Processing core tokens...');
    for (final tokenName in tokenNames) {
      if (tokens.containsKey(tokenName)) {
        processTokens(
            output: output,
            section: tokens[tokenName] as Map<String, dynamic>,
            paths: [],
            category: category,
            tokenValues: tokenValues);
      }
    }

    output.write('}\n');

    return output.toString();
  }
}

/// Generator for theme-specific tokens (light or dark).
///
/// Theme tokens are specific to either light or dark themes and include colors,
/// backgrounds, and other theme-dependent values. This generator creates theme-specific
/// classes (LightTokens, DarkTokens) with static members for each token.
///
class ThemeDesignTokenGenerator extends BaseDesignTokenGenerator {
  /// Creates a new ThemeDesignTokenGenerator with the specified class name and category.
  ///
  /// Parameters:
  /// - className: The name of the class to generate (e.g., LightThemeTokens, DarkThemeTokens)
  /// - category: The token category (categoryLight, categoryDark)
  ThemeDesignTokenGenerator(String className, String category)
      : super(className, category);

  @override
  String generate(Map<String, dynamic> tokens, List<String> tokenNames) {
    final StringBuffer output = StringBuffer()
      ..write(DesignTokenUtils.designTokenFileHeaderComment)
      ..write(
          'import \'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart\';\n\n')
      ..write('/// ${category.capitalize()} theme tokens\n')
      ..write('class $className {\n')
      ..write('  $className._();\n\n');

    // Process theme tokens
    DesignTokenLogger.info('Processing $category theme tokens...');
    for (final tokenName in tokenNames) {
      if (tokens.containsKey(tokenName)) {
        processTokens(
            output: output,
            section: tokens[tokenName] as Map<String, dynamic>,
            paths: [],
            category: category,
            tokenValues: tokenValues);
      }
    }

    output.write('}\n');

    return output.toString();
  }
}

/// Generator for component tokens.
///
/// Component tokens are specific to UI components and include values for buttons,
/// cards, fields, and other UI elements. This generator creates a ComponentDesignTokens
/// class with static members for each token.
///
class ComponentDesignTokenGenerator extends BaseDesignTokenGenerator {
  /// Creates a new ComponentDesignTokenGenerator with the specified class name.
  ///
  /// Parameters:
  /// - className: The name of the class to generate (e.g., ComponentDesignTokens)
  ComponentDesignTokenGenerator(String className)
      : super(className, DesignTokenUtils.categoryComponent);

  @override
  String generate(Map<String, dynamic> tokens, List<String> tokenNames) {
    final StringBuffer output = StringBuffer()
      ..write(DesignTokenUtils.designTokenFileHeaderComment)
      ..write(
          'import \'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart\';\n')
      ..write(
          'import \'package:deriv_chart/src/theme/design_tokens/light_theme_design_tokens.dart\';\n')
      ..write(
          'import \'package:deriv_chart/src/theme/design_tokens/dark_theme_design_tokens.dart\';\n\n')
      ..write('/// Component tokens for UI elements\n')
      ..write('class $className {\n')
      ..write('  $className._();\n\n');

    // Process component tokens
    DesignTokenLogger.info('Processing component tokens...');
    for (final tokenName in tokenNames) {
      if (tokens.containsKey(tokenName)) {
        processTokens(
            output: output,
            section: tokens[tokenName] as Map<String, dynamic>,
            paths: [],
            category: category,
            tokenValues: tokenValues);
      }
    }

    output.write('}\n');

    return output.toString();
  }

  @override
  void processTokens(
      {required StringBuffer output,
      required Map<String, dynamic> section,
      required List<String> paths,
      required String category,
      required Map<String, String> tokenValues}) {
    section.forEach((key, value) {
      if (value is Map) {
        if (value.containsKey('value')) {
          // This is a leaf token with a value
          _processComponentValueToken(output, key,
              value.cast<String, dynamic>(), paths, category, tokenValues);
        } else {
          // This is a nested token group
          _processNestedToken(output, key, value.cast<String, dynamic>(), paths,
              category, tokenValues);
        }
      }
    });
  }

  /// Processes a component token that has a direct value.
  ///
  /// This method creates two copies of each component token variable - one with "Light" suffix
  /// that references the light theme token, and one with "Dark" suffix that references the dark theme token.
  /// For core tokens, it creates a single variable that references CoreDesignTokens directly.
  ///
  /// Parameters:
  /// - output: The StringBuffer to write the generated code to
  /// - key: The token key (name)
  /// - value: The token value and metadata
  /// - paths: The current path in the token hierarchy
  /// - category: The token category (component)
  /// - tokenValues: Map to track processed tokens and avoid duplicates
  ///
  void _processComponentValueToken(
      StringBuffer output,
      String key,
      Map<String, dynamic> value,
      List<String> paths,
      String category,
      Map<String, String> tokenValues) {
    // Cast the map to the correct type
    final Map<String, dynamic> typedValue = value.cast<String, dynamic>();

    // Safely handle first character access
    final String firstChar = key.isNotEmpty ? key[0] : '';
    final String capitalizedKey = key.isNotEmpty
        ? key.replaceFirst(firstChar, firstChar.toUpperCase())
        : key;

    final String tokenName = '${paths.join()}$capitalizedKey';

    // Check if this token name has already been generated
    if (!tokenValues.containsKey(tokenName)) {
      final String rawValue = typedValue['value'].toString();
      final String tokenType = typedValue['type']?.toString() ?? 'default';
      final String tokenValue =
          _formatTokenValue(rawValue, tokenType, category);
      final String description = typedValue.containsKey('description') &&
              typedValue['description'] != null
          ? '/// ${typedValue['description']}'
          : '';
      final isColorToken = tokenType == 'color';
      // Store the token value
      tokenValues[tokenName] = tokenValue;

      // Generate comment text
      String commentText;
      if (description.isNotEmpty) {
        // If there's a description, use it and add the token value
        commentText = '$description (Value: ${typedValue['value']})';
      } else {
        // Generate a comment with just the token value
        commentText = '/// $tokenName with value: ${typedValue['value']}';
      }

      // For component tokens, we need to extract the token path from the raw value
      // The raw value is typically in the format "{semantic.color.monochrome.textIcon.normal.low}"
      // or "{core.color.solid.slate.1400}"
      String tokenPath = rawValue;

      // Remove curly braces if present
      if (tokenPath.startsWith('{') && tokenPath.endsWith('}')) {
        tokenPath = tokenPath.substring(1, tokenPath.length - 1);
      }

      // Check if this is a core token, a structural semantic token, or a regular semantic token
      if (tokenPath.startsWith('core.')) {
        // For core tokens, we use CoreDesignTokens directly
        final String coreTokenName =
            DesignTokenUtils.convertToDartPropertyName(tokenPath, '');

        output
          ..write('  $commentText\n')
          ..write('  static final $tokenName = $coreTokenName;\n\n');
      } else if (tokenPath.startsWith('semantic.') &&
          DesignTokenUtils.isStructuralToken(tokenType)) {
        // For semantic structural tokens (typography, borderRadius, sizing, spacing, etc.),
        // we treat them as core tokens and prefix with CoreDesignTokens
        final String semanticTokenName =
            DesignTokenUtils.convertToDartPropertyName(tokenPath, '');

        output
          ..write('  $commentText\n')
          ..write(
              '  static final $tokenName = CoreDesignTokens.$semanticTokenName;\n\n');
      } else {
        if (isColorToken && tokenPath.startsWith('semantic.')) {
          // For semantic color tokens, we create light and dark versions
          // For regular semantic tokens, we create light and dark versions
          final String semanticTokenName =
              DesignTokenUtils.convertToDartPropertyName(tokenPath, '');

          // Write the light theme version
          output
            ..write('  $commentText\n')
            ..write(
                '  static final ${tokenName}Light = LightThemeDesignTokens.$semanticTokenName;\n\n')

            // Write the dark theme version
            ..write('  $commentText\n')
            ..write(
                '  static final ${tokenName}Dark = DarkThemeDesignTokens.$semanticTokenName;\n\n');
        }
      }
    } else {
      DesignTokenLogger.warning(
          'Duplicate token name detected in $category: $tokenName');
    }
  }
}

/// Factory for creating appropriate token generators based on token category.
///
/// This factory implements the Factory Pattern to create the correct token generator
/// instance based on the token category. It centralizes the creation logic and makes
/// it easy to add new generator types in the future.
///
class DesignTokenGeneratorFactory {
  /// Creates a token generator based on the specified category.
  ///
  /// This factory method returns the appropriate generator instance for the given
  /// token category. It supports core, light, dark, and component token categories.
  ///
  /// Parameters:
  /// - category: The token category (categoryCore, categoryLight, categoryDark, categoryComponent)
  /// - className: The name of the class to generate
  ///
  /// Returns:
  /// A DesignTokenGenerator instance appropriate for the category
  ///
  /// Throws:
  /// ArgumentError if an unknown category is provided
  ///
  static DesignTokenGenerator createGenerator(
      String category, String className) {
    switch (category) {
      case DesignTokenUtils.categoryCore:
        return CoreDesignTokenGenerator();
      case DesignTokenUtils.categoryLight:
      case DesignTokenUtils.categoryDark:
        return ThemeDesignTokenGenerator(className, category);
      case DesignTokenUtils.categoryComponent:
        return ComponentDesignTokenGenerator(className);
      default:
        throw ArgumentError('Unknown token category: $category');
    }
  }
}
