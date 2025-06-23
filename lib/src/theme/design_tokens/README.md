# Design Tokens System

This directory contains the design token system for the Flutter Chart library. The system transforms design tokens from a JSON format into strongly-typed Dart code that can be used throughout the application.

## Overview

Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes. These include colors, typography, spacing, and other visual properties that define the look and feel of the UI.

This system uses a set of files to parse, format, and generate Dart code from design tokens:

-   `tokens.json`: The source of truth for all design tokens (generated from Figma)
-   `design_token_config.json`: Configuration for token categories and output paths
-   `design_token_parser.dart`: Main script for parsing tokens and generating code
-   `design_token_formatters.dart`: Formatters for different token types (colors, dimensions, etc.)
-   `design_token_generators.dart`: Generators for creating Dart classes from tokens
-   `design_token_utils.dart`: Utility functions for token processing
-   `design_token_logger.dart`: Logging utilities for the token generation process

## Design Patterns

The implementation uses several design patterns:

-   **Factory Pattern**: To create appropriate token generators based on token category
-   **Strategy Pattern**: To format token values based on their type
-   **Template Method Pattern**: Base class defines the algorithm structure, subclasses implement specific steps

## Configuration File

The `design_token_config.json` file defines how tokens are organized and where the generated files are placed:

```json
{
	"tokenCategories": {
		"core": {
			"outputPath": "lib/src/theme/design_tokens/core_design_tokens.dart",
			"className": "CoreDesignTokens",
			"tokenNames": [
				"core/border",
				"core/color/solid",
				"core/color/opacity",
				"core/color/gradients",
				"core/boxShadow",
				"core/opacity",
				"core/spacing",
				"core/typography",
				"core/motion",
				"core/sizing",
				"semantic/global",
				"semantic/viewPort/default"
			]
		},
		"light": {
			"outputPath": "lib/src/theme/design_tokens/light_theme_design_tokens.dart",
			"className": "LightThemeDesignTokens",
			"tokenNames": ["semantic/theme/light"]
		},
		"dark": {
			"outputPath": "lib/src/theme/design_tokens/dark_theme_design_tokens.dart",
			"className": "DarkThemeDesignTokens",
			"tokenNames": ["semantic/theme/dark"]
		},
		"component": {
			"outputPath": "lib/src/theme/design_tokens/component_design_tokens.dart",
			"className": "ComponentDesignTokens",
			"tokenNames": ["component/component"]
		}
	}
}
```

### Configuration Structure

-   **tokenCategories**: Groups tokens into categories (core, light, dark, component)
    -   **core**: Tokens shared between light and dark themes (colors, spacing, typography, etc.)
    -   **light**: Light theme-specific tokens
    -   **dark**: Dark theme-specific tokens
    -   **component**: Component-specific tokens with theme variants

For each category:

-   **outputPath**: Where to write the generated Dart file
-   **className**: The name of the generated Dart class
-   **tokenNames**: List of token paths to process from the tokens.json file

## Usage

To generate the design token Dart files:

1. Ensure `tokens.json` is up to date (typically generated from Figma)
2. Run the provided script (recommended):

```bash
bash scripts/generate_and_check_token_files.sh
```

This script:

-   Generates the token files
-   Formats the generated files
-   Auto-fixes common issues
-   Analyzes the files for remaining issues
-   Runs token parser tests

Alternatively, you can run the parser directly:

```bash
dart lib/src/theme/design_tokens/design_token_parser.dart
```

This will generate four Dart files:

-   `core_design_tokens.dart`: Core tokens shared between themes
-   `light_theme_design_tokens.dart`: Light theme-specific tokens
-   `dark_theme_design_tokens.dart`: Dark theme-specific tokens
-   `component_design_tokens.dart`: Component-specific tokens with theme variants

## Token Types and Formatters

The system supports various token types, each with a dedicated formatter that handles the conversion from raw token values to Dart code:

-   **Colors** (`ColorTokenFormatter`):

    -   Handles hex colors (`#RRGGBB`), RGBA colors (`rgba(r,g,b,a)`), token references, and linear gradients
    -   Converts to Flutter `Color` objects or `LinearGradient` objects
    -   Resolves token references in RGBA values and gradients

-   **Dimensions** (`NumericTokenFormatter`):

    -   Handles spacing, sizing, border radius, border width values
    -   Converts pixel values (e.g., `16px`) to numeric values (`16.0`)
    -   Resolves token references to other dimension values

-   **Typography** (`FontTokenFormatter`):

    -   Handles font families, font weights, text decoration
    -   Preserves string values for font families
    -   Resolves token references to typography values

-   **Motion** (`DurationTokenFormatter`, `CubicBezierTokenFormatter`):

    -   Converts duration values (e.g., `300ms`) to Flutter `Duration` objects
    -   Converts cubic-bezier values to Flutter `Curves` or custom `Cubic` objects
    -   Recognizes standard easing curves (linear, ease, easeIn, etc.)

-   **Shadows** (`BoxShadowTokenFormatter`):

    -   Converts shadow definitions to Flutter `BoxShadow` objects
    -   Handles color, offset, blur, and spread values
    -   Supports multiple shadows in an array

-   **Percentages** (`PercentageTokenFormatter`):

    -   Converts percentage values (e.g., `50%`) to decimal values (`0.5`)
    -   Used for opacity and other percentage-based properties

-   **Default** (`_DefaultTokenFormatter`):
    -   Handles any token type not covered by specialized formatters
    -   Provides basic string conversion and token reference resolution

The formatters are managed by the `TokenFormatterFactory`, which returns the appropriate formatter based on the token type.

### Component Tokens

The system supports component-specific tokens (tokens with paths starting with "component" or keys named "component"). These tokens are processed by the ComponentDesignTokenGenerator, which creates:

-   Light theme versions of component tokens (with "Light" suffix)
-   Dark theme versions of component tokens (with "Dark" suffix)
-   Direct references to core tokens when appropriate

Component tokens are generated in the `component_design_tokens.dart` file and can be used to style specific UI components consistently across themes.

## Token Structure in tokens.json

The `tokens.json` file should follow a specific structure for the parser to process it correctly:

```json
{
	"core/color/solid": {
		"core": {
			"color": {
				"solid": {
					"red": {
						"500": {
							"value": "#FF0000",
							"type": "color",
							"description": "Primary red color"
						}
					}
				}
			}
		}
	},
	"semantic/theme/light": {
		"semantic": {
			"color": {
				"monochrome": {
					"surface": {
						"normal": {
							"lowest": {
								"value": "{core.color.opacity.black.75}",
								"type": "color"
							},
							"low": {
								"value": "{core.color.opacity.black.100}",
								"type": "color"
							},
							"midLow": {
								"value": "{core.color.opacity.black.200}",
								"type": "color"
							},
							"midHigh": {
								"value": "{core.color.opacity.black.300}",
								"type": "color"
							},
							"high": {
								"value": "{core.color.opacity.black.700}",
								"type": "color"
							},
							"highest": {
								"value": "{core.color.opacity.black.800}",
								"type": "color"
							}
						},
						"inverse": {
							"lowest": {
								"value": "{core.color.opacity.white.75}",
								"type": "color"
							},
							"low": {
								"value": "{core.color.opacity.white.100}",
								"type": "color"
							},
							"midLow": {
								"value": "{core.color.opacity.white.200}",
								"type": "color"
							},
							"midHigh": {
								"value": "{core.color.opacity.white.300}",
								"type": "color"
							},
							"high": {
								"value": "{core.color.opacity.white.700}",
								"type": "color"
							},
							"highest": {
								"value": "{core.color.opacity.white.800}",
								"type": "color"
							}
						},
						"static": {
							"blackLowest": {
								"value": "{core.color.opacity.black.75}",
								"type": "color"
							},
							"blackLow": {
								"value": "{core.color.opacity.black.100}",
								"type": "color"
							},
							"blackMidLow": {
								"value": "{core.color.opacity.black.200}",
								"type": "color"
							},
							"blackMidHigh": {
								"value": "{core.color.opacity.black.300}",
								"type": "color"
							},
							"blackHigh": {
								"value": "{core.color.opacity.black.700}",
								"type": "color"
							},
							"blackHighest": {
								"value": "{core.color.opacity.black.800}",
								"type": "color"
							},
							"whiteLowest": {
								"value": "{core.color.opacity.white.75}",
								"type": "color"
							},
							"whiteLow": {
								"value": "{core.color.opacity.white.100}",
								"type": "color"
							},
							"whiteMidLow": {
								"value": "{core.color.opacity.white.200}",
								"type": "color"
							},
							"whiteMidHigh": {
								"value": "{core.color.opacity.white.300}",
								"type": "color"
							},
							"whiteHigh": {
								"value": "{core.color.opacity.white.700}",
								"type": "color"
							},
							"whiteHighest": {
								"value": "{core.color.opacity.white.800}",
								"type": "color"
							}
						}
					}
				}
			}
		}
	}
}
```

Each token has:

-   A hierarchical path (e.g., "core/color/solid/red/500")
-   A value (can be a direct value or a reference to another token)
-   A type (color, spacing, etc.)
-   An optional description

## Token Reference Resolution

Token references use the format `{path.to.token}` and are automatically resolved during processing. The system handles references differently based on the token category:

-   **Core tokens referencing other core tokens**: Resolved to direct property references (e.g., `coreColorSolidRed500`)
-   **Light/Dark tokens referencing core tokens**: Resolved to qualified references with the CoreDesignTokens class (e.g., `CoreDesignTokens.coreColorSolidRed500`)
-   **Component tokens referencing core tokens**: Resolved to direct core token references
-   **Component tokens referencing semantic tokens**: Generate both light and dark variants

The reference resolution is handled by the `convertToDartPropertyName` method in `design_token_utils.dart`, which converts dot-notation paths to camelCase property names with appropriate class prefixes based on the context.

## Logging System

The design token system includes a configurable logging system in `design_token_logger.dart` that provides different levels of verbosity:

-   **Error**: Critical errors that prevent functionality
-   **Warning**: Potential issues that don't prevent functionality
-   **Info**: General information about operations (default level)
-   **Debug**: Detailed information for debugging

You can adjust the log level to control the verbosity of the output:

```dart
// Show only errors
DesignTokenLogger.logLevel = LogLevel.error;

// Show everything including debug messages
DesignTokenLogger.logLevel = LogLevel.debug;

// Disable all logging
DesignTokenLogger.logLevel = LogLevel.none;
```

The logger is used throughout the token generation process to provide feedback on the progress and any issues encountered.

## Error Handling and Validation

The design token system includes robust error handling and validation to ensure the generated code is correct:

-   **Configuration validation**: Checks that the configuration file has the required structure
-   **Token path validation**: Verifies that token paths in the configuration exist in the tokens.json file
-   **Token reference validation**: Ensures that referenced tokens exist and can be resolved
-   **Type checking**: Validates that token values match their expected types
-   **Duplicate detection**: Identifies and warns about duplicate token names

Errors and warnings are logged using the logging system, making it easy to identify and fix issues.

## Auto-formatting and Fixing

The `generate_and_check_token_files.sh` script includes steps to ensure the generated code is clean and follows best practices:

1. **Formatting**: Uses `dart format` to ensure consistent code style
2. **Auto-fixing**: Applies `dart fix --apply` to automatically fix common issues
3. **Analysis**: Runs `dart analyze` to identify any remaining issues
4. **Testing**: Executes the token parser tests to verify functionality

This process helps maintain high-quality generated code that integrates seamlessly with the rest of the application.

## Testing Framework

The design token system includes a comprehensive test suite in `design_token_parser_test.dart` that verifies the correct functioning of the token parsing and generation process:

-   **RGBA Transformation Tests**: Verify that RGBA color strings with token references are correctly transformed
-   **Linear Gradient Tests**: Check that gradient strings are properly formatted and converted
-   **Cubic Bezier Tests**: Ensure that cubic-bezier curves are recognized and converted correctly
-   **Token Name Conversion Tests**: Validate that token references are properly converted to Dart property names
-   **Formatter Factory Tests**: Verify that the correct formatters are returned for different token types

These tests help ensure the reliability of the token system and catch any regressions when making changes.

## Integration with Flutter Applications

To use the generated design tokens in your Flutter application:

1. Import the generated files:

```dart
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/light_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/dark_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/component_design_tokens.dart';
```

2. Use the tokens in your code:

```dart
// Using core tokens
final spacing = CoreDesignTokens.coreSpacing8;
final color = CoreDesignTokens.coreColorSolidRed500;

// Using theme-specific tokens
final lightBackground = LightThemeDesignTokens.backgroundPrimary;
final darkBackground = DarkThemeDesignTokens.backgroundPrimary;

// Using component tokens
final buttonColorLight = ComponentDesignTokens.buttonPrimaryBackgroundLight;
final buttonColorDark = ComponentDesignTokens.buttonPrimaryBackgroundDark;
```

3. Create a theme switcher that uses the appropriate tokens based on the current theme.

## Troubleshooting

### Empty Token Files

If the generated files don't contain any tokens (token count is 0), check:

-   The structure of your `tokens.json` file matches the expected format
-   The token paths in `design_token_config.json` match the paths in your `tokens.json` file
-   There are no syntax errors in your `tokens.json` file

### Missing References

If you see errors about missing token references:

-   Ensure all referenced tokens exist in the `tokens.json` file
-   Check that the reference syntax is correct (`{path.to.token}`)
-   Verify that the referenced token is included in the `tokenNames` list in the configuration

### Import Errors

If you see import errors when using the generated files:

-   Ensure the files have been generated successfully
-   Check that the import paths are correct
-   Run `flutter pub get` to update dependencies

## Extension

To add support for new token types:

1. Add a new formatter in `design_token_formatters.dart`
2. Register the formatter in `TokenFormatterFactory`
3. Update tests in `design_token_parser_test.dart`
