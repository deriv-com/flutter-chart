/// Design Token Parser
///
/// This file contains the main functionality for parsing design tokens from a JSON file
/// and generating Dart code files that can be used in the application. The parser handles
/// different token categories (core, light theme, dark theme) and uses specialized formatters
/// to transform token values into appropriate Dart code.
///
/// The workflow is as follows:
/// 1. Load configuration (from token_config.json or use default)
/// 2. Test parsers with example inputs to ensure they work correctly
/// 3. Reset token tracking maps to avoid duplicates
/// 4. Process the tokens.json file:
///    - Parse JSON content
///    - Process each token category (core, light, dark)
///    - Generate Dart files with token values
///
/// The parser supports various token types including colors, gradients, typography,
/// spacing, and more. It uses specialized formatters to handle different token formats
/// and convert them to appropriate Dart objects.

import 'dart:convert';
import 'dart:io';

import 'design_token_utils.dart';
import 'design_token_generators.dart';
import 'design_token_formatters.dart';
import 'design_token_logger.dart';

/// Main entry point for the token parser
///
/// Executes the token parsing process:
/// 1. Loads configuration from design_token_config.json or uses default configuration
/// 2. Tests parsers with example inputs to ensure they work correctly
/// 3. Resets token tracking maps to avoid duplicates
/// 4. Processes the tokens.json file and generates Dart code files for each token category
///
/// This function handles exceptions and exits with an error code if the parsing fails.
void main() {
  try {
    // Load configuration
    final config = loadConfiguration();

    // Test the parsers with examples
    testParsers();

    // Reset the token tracking maps before processing
    resetTokenMaps();

    // Process the tokens.json file and generate token files
    processTokensFile(config);
  } on Exception catch (e) {
    DesignTokenLogger.error('$e');
    exit(1);
  }
}

/// Maps to track processed tokens to avoid duplicates
///
/// These maps store token values that have been processed for each theme category.
/// The key is the token name/path and the value is the processed Dart code.
/// This helps prevent duplicate token processing and enables reference tracking.
///
/// There are separate maps for each token category (core, light, dark) to maintain
/// isolation between different theme contexts.

/// Core token values map
///
/// Stores processed core token values (colors, spacing, typography, etc.)
Map<String, String> coreTokenValues = {};

/// Light theme token values map
///
/// Stores processed light theme-specific token values
Map<String, String> lightThemeTokenValues = {};

/// Dark theme token values map
///
/// Stores processed dark theme-specific token values
Map<String, String> darkThemeTokenValues = {};

/// Component token values map
///
/// Stores processed component-specific token values
Map<String, String> componentTokenValues = {};

/// Reset token tracking maps
///
/// Clears all token tracking maps before processing a new set of tokens.
/// This ensures that no residual data from previous runs affects the current processing.
void resetTokenMaps() {
  coreTokenValues = {};
  lightThemeTokenValues = {};
  darkThemeTokenValues = {};
  componentTokenValues = {};
}

/// Load configuration from design_token_config.json
///
/// Attempts to read and parse the configuration file from the predefined path (configPath).
/// If the file doesn't exist or can't be parsed, falls back to the default configuration.
///
/// The configuration file defines:
/// - Token categories (core, light, dark)
/// - Output paths for generated Dart files
/// - Class names for generated token classes
/// - Token names/paths to process from tokens.json
///
/// Returns:
///   A Map<String, dynamic> containing the configuration settings for token processing.
///
/// Throws:
///   Logs an error message if the configuration file exists but cannot be parsed.
Map<String, dynamic> loadConfiguration() {
  try {
    final configFile = File(DesignTokenUtils.configPath);
    if (!configFile.existsSync()) {
      DesignTokenLogger.warning(
          'Configuration file not found at ${DesignTokenUtils.configPath}. Using default configuration.');
      return defaultConfiguration;
    }

    try {
      final String configContent = configFile.readAsStringSync();
      final Map<String, dynamic> config = jsonDecode(configContent);

      // Validate configuration structure
      if (!_validateConfiguration(config)) {
        DesignTokenLogger.warning(
            'Invalid configuration structure in ${DesignTokenUtils.configPath}. Using default configuration.');
        return defaultConfiguration;
      }

      return config;
    } on FileSystemException catch (e) {
      DesignTokenLogger.error(
          'Error reading configuration file: ${e.message}. Path: ${e.path}. OSError: ${e.osError}');
      return defaultConfiguration;
    } on FormatException catch (e) {
      DesignTokenLogger.error(
          'Invalid JSON format in configuration file: ${e.message}. Source: ${e.source}');
      return defaultConfiguration;
    }
  } on Exception catch (e) {
    DesignTokenLogger.error('Unexpected error loading configuration: $e');
    return defaultConfiguration;
  }
}

/// Validates the configuration structure
///
/// Checks if the configuration has the required structure:
/// - tokenCategories map
/// - Each category has outputPath, className, and tokenNames
///
/// Returns:
///   true if the configuration is valid, false otherwise
bool _validateConfiguration(Map<String, dynamic> config) {
  if (!config.containsKey('tokenCategories')) {
    DesignTokenLogger.error('Configuration missing "tokenCategories" key');
    return false;
  }

  final tokenCategories = config['tokenCategories'];
  if (tokenCategories is! Map<String, dynamic>) {
    DesignTokenLogger.error('Configuration "tokenCategories" is not a map');
    return false;
  }

  for (final category in tokenCategories.entries) {
    final categoryConfig = category.value;
    if (categoryConfig is! Map<String, dynamic>) {
      DesignTokenLogger.error('Category "${category.key}" is not a map');
      return false;
    }

    if (!categoryConfig.containsKey('outputPath')) {
      DesignTokenLogger.error(
          'Category "${category.key}" missing "outputPath"');
      return false;
    }

    if (!categoryConfig.containsKey('className')) {
      DesignTokenLogger.error('Category "${category.key}" missing "className"');
      return false;
    }

    if (!categoryConfig.containsKey('tokenNames')) {
      DesignTokenLogger.error(
          'Category "${category.key}" missing "tokenNames"');
      return false;
    }

    final tokenNames = categoryConfig['tokenNames'];
    if (tokenNames is! List) {
      DesignTokenLogger.error(
          'Category "${category.key}" "tokenNames" is not a list');
      return false;
    }
  }

  return true;
}

/// Default configuration if config file is not found
///
/// This configuration defines the token categories, output paths, class names,
/// and token names to process for each category. It's used when the configuration
/// file cannot be found or loaded.
///
/// Structure:
/// - tokenCategories: Map of category configurations
///   - core: Core design tokens (colors, spacing, typography, etc.)
///   - light: Light theme-specific tokens
///   - dark: Dark theme-specific tokens
///
/// Each category contains:
/// - outputPath: Where to write the generated Dart file
/// - className: The name of the generated Dart class
/// - tokenNames: List of token paths to process from the tokens.json file
final Map<String, dynamic> defaultConfiguration = {
  'tokenCategories': {
    'core': {
      'outputPath': DesignTokenUtils.coreDesignTokensPath,
      'className': 'CoreDesignTokens',
      'tokenNames': [
        'core/border',
        'core/color/solid',
        'core/color/opacity',
        'core/color/gradients',
        'core/boxShadow',
        'core/opacity',
        'core/spacing',
        'core/typography',
        'core/motion',
        'core/sizing',
        'semantic/global',
        'semantic/viewPort/default',
      ]
    },
    'light': {
      'outputPath': DesignTokenUtils.lightThemeDesignTokensPath,
      'className': 'LightThemeDesignTokens',
      'tokenNames': ['semantic/theme/light']
    },
    'dark': {
      'outputPath': DesignTokenUtils.darkThemeDesignTokensPath,
      'className': 'DarkThemeDesignTokens',
      'tokenNames': ['semantic/theme/dark']
    },
    'component': {
      'outputPath': DesignTokenUtils.componentDesignTokensPath,
      'className': 'ComponentDesignTokens',
      'tokenNames': ['component/component']
    }
  }
};

/// Process the tokens.json file and generate token files
///
/// This is the main function that reads the tokens.json file, parses its content,
/// and processes each token category (core, light, dark) to generate the corresponding
/// Dart files.
///
/// The function:
/// 1. Reads the tokens.json file
/// 2. Parses the JSON content
/// 3. Processes each token category using the provided configuration
/// 4. Logs the number of tokens processed for each category
///
/// The generated Dart files contain strongly-typed classes with static members
/// for each design token, providing type-safe access to design tokens in the application.
///
/// Parameters:
///   config - The configuration map containing token categories, output paths, and class names
///
/// Throws:
///   FileSystemException - If the tokens.json file is not found or cannot be read
///   FormatException - If the tokens.json file contains invalid JSON
///   ArgumentError - If the configuration is invalid
///   Other exceptions that might occur during processing (which are rethrown)
void processTokensFile(Map<String, dynamic> config) {
  try {
    // Validate config structure
    if (!config.containsKey('tokenCategories')) {
      throw ArgumentError(
          'Invalid configuration: missing "tokenCategories" key');
    }

    final tokenCategories = config['tokenCategories'];
    if (tokenCategories is! Map<String, dynamic>) {
      throw ArgumentError(
          'Invalid configuration: "tokenCategories" is not a map');
    }

    // Required categories
    final requiredCategories = ['core', 'light', 'dark', 'component'];
    for (final category in requiredCategories) {
      if (!tokenCategories.containsKey(category)) {
        DesignTokenLogger.warning('Configuration missing "$category" category');
      }
    }

    // Check if tokens.json exists
    final file = File(DesignTokenUtils.tokensJsonPath);
    if (!file.existsSync()) {
      throw const FileSystemException(
          'Tokens file not found', DesignTokenUtils.tokensJsonPath);
    }

    DesignTokenLogger.info('\nParsing ${file.path}...');

    // Read tokens.json with error handling
    String jsonContent;
    try {
      jsonContent = file.readAsStringSync();
    } on FileSystemException catch (e) {
      throw FileSystemException(
          'Error reading tokens file: ${e.message}', e.path, e.osError);
    }

    // Parse JSON with error handling
    final Map<String, dynamic> tokens;
    try {
      final dynamic decodedJson = jsonDecode(jsonContent);
      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException(
            'Invalid tokens.json format: root element is not an object');
      }
      tokens = decodedJson;
    } on FormatException catch (e) {
      throw FormatException(
          'Invalid JSON format in ${file.path}: ${e.message}', e.source);
    }

    // Validate tokens structure
    if (tokens.isEmpty) {
      DesignTokenLogger.warning('tokens.json is empty');
    }

    // Process each token category
    int successCount = 0;

    // Process core tokens if available
    if (tokenCategories.containsKey('core')) {
      try {
        _processTokenCategory(tokens, tokenCategories['core'],
            DesignTokenUtils.categoryCore, coreTokenValues);
        successCount++;
      } on Exception catch (e) {
        DesignTokenLogger.error('Error processing core tokens: $e');
      }
    }

    // Process light theme tokens if available
    if (tokenCategories.containsKey('light')) {
      try {
        _processTokenCategory(tokens, tokenCategories['light'],
            DesignTokenUtils.categoryLight, lightThemeTokenValues);
        successCount++;
      } on Exception catch (e) {
        DesignTokenLogger.error('Error processing light theme tokens: $e');
      }
    }

    // Process dark theme tokens if available
    if (tokenCategories.containsKey('dark')) {
      try {
        _processTokenCategory(tokens, tokenCategories['dark'],
            DesignTokenUtils.categoryDark, darkThemeTokenValues);
        successCount++;
      } on Exception catch (e) {
        DesignTokenLogger.error('Error processing dark theme tokens: $e');
      }
    }

    // Process component tokens if available
    if (tokenCategories.containsKey('component')) {
      try {
        _processTokenCategory(tokens, tokenCategories['component'],
            DesignTokenUtils.categoryComponent, componentTokenValues);
        successCount++;
      } on Exception catch (e) {
        DesignTokenLogger.error('Error processing component tokens: $e');
      }
    }

    // Print token counts
    DesignTokenLogger.info('Core tokens: ${coreTokenValues.length}');
    DesignTokenLogger.info(
        'Light theme tokens: ${lightThemeTokenValues.length}');
    DesignTokenLogger.info('Dark theme tokens: ${darkThemeTokenValues.length}');
    DesignTokenLogger.info('Component tokens: ${componentTokenValues.length}');

    // Check if any categories were processed successfully
    if (successCount == 0) {
      throw Exception('Failed to process any token categories');
    }

    // Check if any tokens were generated
    if (coreTokenValues.isEmpty &&
        lightThemeTokenValues.isEmpty &&
        darkThemeTokenValues.isEmpty &&
        componentTokenValues.isEmpty) {
      DesignTokenLogger.warning(
          'No tokens were generated. Check if tokens.json has the expected structure and paths match the configuration.');
    }
  } on FileSystemException catch (e) {
    DesignTokenLogger.error('File system error: ${e.message}. Path: ${e.path}');
    rethrow;
  } on FormatException catch (e) {
    DesignTokenLogger.error('Format error: ${e.message}');
    rethrow;
  } on ArgumentError catch (e) {
    DesignTokenLogger.error('Configuration error: ${e.message}');
    rethrow;
  } catch (e) {
    DesignTokenLogger.error('Error processing tokens file: $e');
    rethrow;
  }
}

/// Process a token category
///
/// This private helper function processes a specific token category (core, light, dark)
/// using the provided configuration. It creates the appropriate token generator,
/// generates the token file content, and writes it to the specified output path.
///
/// The function:
/// 1. Extracts configuration values (class name, output path, token names)
/// 2. Creates a token generator using the DesignTokenGeneratorFactory
/// 3. Generates the token file content by processing the specified token names
/// 4. Writes the generated content to the output file
///
/// Parameters:
///   tokens - The complete tokens map from the tokens.json file
///   categoryConfig - Configuration for this specific category (output path, class name, token names)
///   category - The category identifier (categoryCore, categoryLight, categoryDark)
///   tokenValues - The map to store processed token values for this category
///
/// Throws:
///   ArgumentError - If the token category is unknown
///   FileSystemException - If there's an error writing to the output file
///   FormatException - If there's an error generating the token content
void _processTokenCategory(
    Map<String, dynamic> tokens,
    Map<String, dynamic> categoryConfig,
    String category,
    Map<String, String> tokenValues) {
  try {
    final String className = categoryConfig['className'];
    final String outputPath = categoryConfig['outputPath'];
    final List<dynamic> tokenNames = categoryConfig['tokenNames'];

    // Validate token names exist in the tokens map
    _validateTokenNames(tokens, tokenNames, category);

    // Create the appropriate generator using the factory
    final DesignTokenGenerator generator;
    try {
      generator =
          DesignTokenGeneratorFactory.createGenerator(category, className);
    } catch (e) {
      throw ArgumentError(
          'Failed to create generator for category "$category": $e');
    }

    // Generate the token file content
    String content;
    try {
      content = generator.generate(tokens, List<String>.from(tokenNames));

      // Copy the generator's token values to the global map
      if (generator is BaseDesignTokenGenerator) {
        tokenValues.addAll(generator.tokenValues);
      }
    } catch (e) {
      throw FormatException(
          'Error generating token content for category "$category": $e');
    }

    // Write the content to the output file
    try {
      generator.writeToFile(content, outputPath);
    } on FileSystemException catch (e) {
      throw FileSystemException(
          'Error writing token file for category "$category"',
          outputPath,
          e.osError);
    }
  } catch (e) {
    DesignTokenLogger.error('Error processing token category "$category": $e');
    rethrow;
  }
}

/// Validates that token names exist in the tokens map
///
/// Checks if each token name in the tokenNames list exists in the tokens map.
/// Logs a warning for each token name that doesn't exist.
///
/// Parameters:
///   tokens - The complete tokens map from the tokens.json file
///   tokenNames - The list of token names to validate
///   category - The category identifier (categoryCore, categoryLight, categoryDark)
void _validateTokenNames(
    Map<String, dynamic> tokens, List<dynamic> tokenNames, String category) {
  for (final tokenName in tokenNames) {
    if (tokenName is String && !tokens.containsKey(tokenName)) {
      DesignTokenLogger.warning(
          'Token name "$tokenName" not found in tokens.json for category "$category"');
    }
  }
}

/// Test the parsers with examples
///
/// This function tests various token formatters and parsers with example inputs to ensure
/// they work correctly before processing the actual tokens. This helps catch any issues
/// with the parsing logic early in the process.
///
/// It tests the following formatters:
///
/// 1. RGBA color formatter - Tests transforming RGBA strings with token references
/// 2. Linear gradient formatter - Tests transforming gradient strings with token references
/// 3. Gradient to Dart object converter - Tests converting gradient strings to Dart LinearGradient objects
/// 4. Numeric token reference converter - Tests converting token references to Dart property names
/// 5. Cubic bezier formatter - Tests converting cubic-bezier strings to Dart Curves objects
///
/// Each formatter is tested with different token categories (core, light, dark) to ensure
/// proper handling of token references in different contexts.
///
/// The results are logged using DesignTokenLogger.debug for inspection during development.
/// These tests are only run in debug mode and don't affect the actual token generation.
void testParsers() {
  try {
    DesignTokenLogger.debug('Starting parser tests...');

    // Get color formatter
    final DesignTokenValueFormatter colorFormatter;
    try {
      colorFormatter = TokenFormatterFactory.getFormatter('color');
      if (!(colorFormatter is ColorTokenFormatter)) {
        DesignTokenLogger.warning(
            'Color formatter is not a ColorTokenFormatter');
      }
    } on Exception catch (e) {
      DesignTokenLogger.error('Error getting color formatter: $e');
      return;
    }

    // Test the rgba parser with different categories
    try {
      _testRgbaParser(colorFormatter);
    } on Exception catch (e) {
      DesignTokenLogger.error('Error testing RGBA parser: $e');
    }

    // Test the linear gradient parser with different categories
    try {
      _testLinearGradientParser();
    } on Exception catch (e) {
      DesignTokenLogger.error('Error testing linear gradient parser: $e');
    }

    // Test the gradient string to LinearGradient conversion
    try {
      _testGradientToDartObject(colorFormatter);
    } on Exception catch (e) {
      DesignTokenLogger.error(
          'Error testing gradient to Dart object conversion: $e');
    }

    // Test numeric token references
    try {
      _testNumericTokenReferences();
    } on Exception catch (e) {
      DesignTokenLogger.error('Error testing numeric token references: $e');
    }

    // Test cubic-bezier parser
    try {
      _testCubicBezierParser();
    } on Exception catch (e) {
      DesignTokenLogger.error('Error testing cubic-bezier parser: $e');
    }

    DesignTokenLogger.debug('Parser tests completed.');
  } on Exception catch (e) {
    DesignTokenLogger.error('Unexpected error in testParsers: $e');
  }
}

/// Test the RGBA parser with different categories
void _testRgbaParser(DesignTokenValueFormatter colorFormatter) {
  const String rgbaInput =
      'rgba({core.color.solid.magenta.700},{core.opacity.700})';

  DesignTokenLogger.debug('RGBA Original: $rgbaInput');

  // Test with different categories
  DesignTokenLogger.debug('\nCore category:');
  final String transformedCore = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.transformRgbaTokenString(
          rgbaInput, DesignTokenUtils.categoryCore)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $transformedCore');

  DesignTokenLogger.debug('\nLight category:');
  final String transformedLight = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.transformRgbaTokenString(
          rgbaInput, DesignTokenUtils.categoryLight)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $transformedLight');

  DesignTokenLogger.debug('\nDark category:');
  final String transformedDark = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.transformRgbaTokenString(
          rgbaInput, DesignTokenUtils.categoryDark)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $transformedDark');
}

/// Test the linear gradient parser with different categories
void _testLinearGradientParser() {
  const String gradientInput =
      'linear-gradient(1.93deg, {core.color.opacity.overflow.100} 1.56%, {core.color.solid.slate.50} 49.91%)';
  DesignTokenLogger.debug('\n\nGRADIENT Original: $gradientInput');

  // Test with different categories
  DesignTokenLogger.debug('\nCore category:');
  final String gradientCore = DesignTokenUtils.formatLinearGradientValue(
      gradientInput, DesignTokenUtils.categoryCore);
  DesignTokenLogger.debug('Transformed: $gradientCore');

  DesignTokenLogger.debug('\nLight category:');
  final String gradientLight = DesignTokenUtils.formatLinearGradientValue(
      gradientInput, DesignTokenUtils.categoryLight);
  DesignTokenLogger.debug('Transformed: $gradientLight');

  DesignTokenLogger.debug('\nDark category:');
  final String gradientDark = DesignTokenUtils.formatLinearGradientValue(
      gradientInput, DesignTokenUtils.categoryDark);
  DesignTokenLogger.debug('Transformed: $gradientDark');
}

/// Test the gradient string to LinearGradient conversion
void _testGradientToDartObject(DesignTokenValueFormatter colorFormatter) {
  const String dartGradientInput =
      'linear-gradient(1.93deg, {core.color.opacity.overflow.100} 1.56%, {core.color.solid.slate.50} 49.91%)';
  DesignTokenLogger.debug('\n\nDART GRADIENT Original: $dartGradientInput');

  // Test with different categories
  DesignTokenLogger.debug('\nCore category:');
  final String dartGradientCore = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.convertGradientStringToDartObject(
          dartGradientInput, DesignTokenUtils.categoryCore)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $dartGradientCore');

  DesignTokenLogger.debug('\nLight category:');
  final String dartGradientLight = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.convertGradientStringToDartObject(
          dartGradientInput, DesignTokenUtils.categoryLight)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $dartGradientLight');

  DesignTokenLogger.debug('\nDark category:');
  final String dartGradientDark = (colorFormatter is ColorTokenFormatter)
      ? colorFormatter.convertGradientStringToDartObject(
          dartGradientInput, DesignTokenUtils.categoryDark)
      : 'Invalid formatter';
  DesignTokenLogger.debug('Transformed: $dartGradientDark');
}

/// Test numeric token references
void _testNumericTokenReferences() {
  const String numericTokenInput = '{core.elevation.shadow.730}';
  DesignTokenLogger.debug('\n\nNUMERIC TOKEN Original: $numericTokenInput');

  if (numericTokenInput.length < 2 ||
      !numericTokenInput.startsWith('{') ||
      !numericTokenInput.endsWith('}')) {
    DesignTokenLogger.error(
        'Invalid token reference format: $numericTokenInput');
    return;
  }

  // Extract the token reference (remove the curly braces)
  final String numericTokenRef =
      numericTokenInput.substring(1, numericTokenInput.length - 1);

  // Test with different categories
  DesignTokenLogger.debug('\nCore category:');
  final String numericTokenCore = DesignTokenUtils.convertToDartPropertyName(
      numericTokenRef, DesignTokenUtils.categoryCore);
  DesignTokenLogger.debug('Transformed: $numericTokenCore');

  DesignTokenLogger.debug('\nLight category:');
  final String numericTokenLight = DesignTokenUtils.convertToDartPropertyName(
      numericTokenRef, DesignTokenUtils.categoryLight);
  DesignTokenLogger.debug('Transformed: $numericTokenLight');

  DesignTokenLogger.debug('\nDark category:');
  final String numericTokenDark = DesignTokenUtils.convertToDartPropertyName(
      numericTokenRef, DesignTokenUtils.categoryDark);
  DesignTokenLogger.debug('Transformed: $numericTokenDark');
}

/// Test cubic-bezier parser
void _testCubicBezierParser() {
  const String cubicBezierInput = 'cubic-bezier(0, 0, 1, 1)';
  DesignTokenLogger.debug('\n\nCUBIC BEZIER Original: $cubicBezierInput');

  try {
    // Create a CubicBezierTokenFormatter directly
    final formatter = CubicBezierTokenFormatter();
    final String cubicBezierTransformed =
        formatter.convertCubicBezierToDartObject(cubicBezierInput);
    DesignTokenLogger.debug('Transformed: $cubicBezierTransformed');

    // Test another cubic-bezier value
    const String cubicBezierInput2 = 'cubic-bezier(0.42, 0, 1, 1)';
    DesignTokenLogger.debug('\nCUBIC BEZIER 2 Original: $cubicBezierInput2');
    final String cubicBezierTransformed2 =
        formatter.convertCubicBezierToDartObject(cubicBezierInput2);
    DesignTokenLogger.debug('Transformed: $cubicBezierTransformed2');
  } on Exception catch (e) {
    DesignTokenLogger.error('Error in cubic bezier transformation: $e');
  }
}
