/// Design Token Parser Tests
///
/// This file contains unit tests for the design token parsing system. It verifies
/// that the token formatters and utilities correctly transform design tokens into
/// the expected Dart code for different token categories (core, light, dark).
///
/// The tests cover:
/// - RGBA color transformations
/// - Linear gradient formatting and conversion
/// - Cubic bezier curve recognition and conversion
/// - Token name conversion for different categories
/// - Formatter factory functionality
///
/// These tests ensure that the design token system correctly handles different
/// token formats and produces the expected Dart code output.

import 'package:flutter_test/flutter_test.dart';
import 'package:deriv_chart/src/theme/design_tokens/design_token_formatters.dart';
import 'package:deriv_chart/src/theme/design_tokens/design_token_utils.dart';

void main() {
  group('Token Parser Tests', () {
    /// Tests for RGBA color transformations
    ///
    /// These tests verify that RGBA color strings with token references are correctly
    /// transformed into Color.fromRGBO expressions with the appropriate token references
    /// for different token categories (core, light, dark).
    group('RGBA Transformation Tests', () {
      /// Tests that RGBA transformation works correctly for core category tokens
      ///
      /// Verifies that token references in RGBA strings are correctly transformed
      /// to camelCase property names for the core category.
      test('RGBA Transformation - Core Category', () {
        String input =
            "rgba({core.color.solid.magenta.700},{core.opacity.700})";
        String expected =
            "Color.fromRGBO(coreColorSolidMagenta700.red, coreColorSolidMagenta700.green, coreColorSolidMagenta700.blue, coreOpacity700)";
        String result =
            (TokenFormatterFactory.getFormatter('color') as ColorTokenFormatter)
                .transformRgbaTokenString(input, DesignTokenUtils.categoryCore);
        expect(result, equals(expected));
      });

      /// Tests that RGBA transformation works correctly for light category tokens
      ///
      /// Verifies that core token references in light theme context are correctly
      /// prefixed with CoreDesignTokens.
      test('RGBA Transformation - Light Category', () {
        String input =
            "rgba({core.color.solid.magenta.700},{core.opacity.700})";
        String expected =
            "Color.fromRGBO(CoreDesignTokens.coreColorSolidMagenta700.red, CoreDesignTokens.coreColorSolidMagenta700.green, CoreDesignTokens.coreColorSolidMagenta700.blue, CoreDesignTokens.coreOpacity700)";
        String result = (TokenFormatterFactory.getFormatter('color')
                as ColorTokenFormatter)
            .transformRgbaTokenString(input, DesignTokenUtils.categoryLight);
        expect(result, equals(expected));
      });

      /// Tests that RGBA transformation works correctly for dark category tokens
      ///
      /// Verifies that core token references in dark theme context are correctly
      /// prefixed with CoreDesignTokens.
      test('RGBA Transformation - Dark Category', () {
        String input =
            "rgba({core.color.solid.magenta.700},{core.opacity.700})";
        String expected =
            "Color.fromRGBO(CoreDesignTokens.coreColorSolidMagenta700.red, CoreDesignTokens.coreColorSolidMagenta700.green, CoreDesignTokens.coreColorSolidMagenta700.blue, CoreDesignTokens.coreOpacity700)";
        String result =
            (TokenFormatterFactory.getFormatter('color') as ColorTokenFormatter)
                .transformRgbaTokenString(input, DesignTokenUtils.categoryDark);
        expect(result, equals(expected));
      });
    });

    /// Tests for linear gradient formatting and conversion
    ///
    /// These tests verify that linear gradient strings with token references are correctly
    /// formatted and converted to Flutter LinearGradient objects for different token categories.
    group('Linear Gradient Tests', () {
      /// Tests linear gradient formatting for core category
      ///
      /// Verifies that token references in linear gradients are correctly
      /// transformed to camelCase property names.
      test('Linear Gradient Formatting - Core Category', () {
        String input =
            "linear-gradient(1.93deg, {core.color.opacity.overflow.100} 1.56%, {core.color.solid.slate.50} 49.91%)";
        String result = DesignTokenUtils.formatLinearGradientValue(
            input, DesignTokenUtils.categoryCore);
        expect(result, contains("coreColorOpacityOverflow100"));
        expect(result, contains("coreColorSolidSlate50"));
      });

      /// Tests linear gradient formatting for light category
      ///
      /// Verifies that core token references in light theme context are correctly
      /// prefixed with CoreDesignTokens.
      test('Linear Gradient Formatting - Light Category', () {
        String input =
            "linear-gradient(1.93deg, {core.color.opacity.overflow.100} 1.56%, {core.color.solid.slate.50} 49.91%)";
        String result = DesignTokenUtils.formatLinearGradientValue(
            input, DesignTokenUtils.categoryLight);
        expect(
            result, contains("CoreDesignTokens.coreColorOpacityOverflow100"));
        expect(result, contains("CoreDesignTokens.coreColorSolidSlate50"));
      });

      /// Tests conversion of linear gradient strings to Flutter LinearGradient objects
      ///
      /// Verifies that the gradient is correctly parsed with proper angle, colors, and stops.
      test('Linear Gradient to Dart Object - Core Category', () {
        String input =
            "linear-gradient(1.93deg, {core.color.opacity.overflow.100} 1.56%, {core.color.solid.slate.50} 49.91%)";
        String result =
            (TokenFormatterFactory.getFormatter('color') as ColorTokenFormatter)
                .convertGradientStringToDartObject(
                    input, DesignTokenUtils.categoryCore);
        expect(result, contains("LinearGradient("));
        expect(
            result,
            contains(
                "colors: [coreColorOpacityOverflow100, coreColorSolidSlate50]"));
        expect(result, contains("stops: [0.015600000000000001, 0.4991]"));
      });
    });

    /// Tests for cubic bezier curve recognition and conversion
    ///
    /// These tests verify that cubic-bezier strings are correctly recognized and
    /// converted to appropriate Flutter Curves or Cubic objects.
    group('Cubic Bezier Tests', () {
      /// Tests recognition of linear cubic bezier curves
      ///
      /// Verifies that cubic-bezier(0, 0, 1, 1) is correctly recognized as
      /// Flutter's Curves.linear and includes appropriate documentation.
      test('Cubic Bezier - Linear', () {
        String input = "cubic-bezier(0, 0, 1, 1)";
        String result =
            CubicBezierTokenFormatter().convertCubicBezierToDartObject(input);
        expect(result, contains("Curves.linear"));
      });

      /// Tests recognition of ease cubic bezier curves
      ///
      /// Verifies that cubic-bezier(0.42, 0, 1, 1) is correctly recognized as
      /// Flutter's Curves.ease and includes appropriate documentation.
      test('Cubic Bezier - Ease', () {
        String input = "cubic-bezier(0.42, 0, 1, 1)";
        String result =
            CubicBezierTokenFormatter().convertCubicBezierToDartObject(input);
        expect(result, contains("Curves.ease"));
      });

      /// Tests handling of custom cubic bezier curves
      ///
      /// Verifies that custom cubic bezier values are correctly converted to
      /// Flutter's Cubic constructor with the appropriate parameters.
      test('Cubic Bezier - Custom', () {
        String input = "cubic-bezier(0.1, 0.2, 0.3, 0.4)";
        String result =
            CubicBezierTokenFormatter().convertCubicBezierToDartObject(input);
        expect(result, contains("Cubic(0.1, 0.2, 0.3, 0.4)"));
      });
    });

    /// Tests for motion token formatting
    ///
    /// These tests verify that motion tokens (both cubic-bezier and CSS easing values)
    /// are correctly formatted to valid Flutter Curve instances, addressing the bug
    /// where non-bezier values were incorrectly formatted as string literals.
    group('Motion Token Tests', () {
      /// Tests that cubic-bezier values are handled correctly by MotionTokenFormatter
      ///
      /// Verifies that the MotionTokenFormatter correctly delegates cubic-bezier
      /// values to the CubicBezierTokenFormatter.
      test('Motion Token - Cubic Bezier', () {
        String input = "cubic-bezier(0.42, 0, 1, 1)";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.ease"));
      });

      /// Tests that CSS 'ease' values are mapped to Flutter Curves
      ///
      /// Verifies that the CSS 'ease' keyword is correctly mapped to
      /// Flutter's Curves.ease constant instead of a string literal.
      test('Motion Token - CSS Ease', () {
        String input = "ease";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.ease"));
        expect(result, isNot(contains("'ease'")));
      });

      /// Tests that CSS 'ease-in' values are mapped to Flutter Curves
      ///
      /// Verifies that the CSS 'ease-in' keyword is correctly mapped to
      /// Flutter's Curves.easeIn constant instead of a string literal.
      test('Motion Token - CSS Ease In', () {
        String input = "ease-in";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.easeIn"));
        expect(result, isNot(contains("'ease-in'")));
      });

      /// Tests that CSS 'ease-out' values are mapped to Flutter Curves
      ///
      /// Verifies that the CSS 'ease-out' keyword is correctly mapped to
      /// Flutter's Curves.easeOut constant instead of a string literal.
      test('Motion Token - CSS Ease Out', () {
        String input = "ease-out";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.easeOut"));
        expect(result, isNot(contains("'ease-out'")));
      });

      /// Tests that CSS 'ease-in-out' values are mapped to Flutter Curves
      ///
      /// Verifies that the CSS 'ease-in-out' keyword is correctly mapped to
      /// Flutter's Curves.easeInOut constant instead of a string literal.
      test('Motion Token - CSS Ease In Out', () {
        String input = "ease-in-out";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.easeInOut"));
        expect(result, isNot(contains("'ease-in-out'")));
      });

      /// Tests that CSS 'linear' values are mapped to Flutter Curves
      ///
      /// Verifies that the CSS 'linear' keyword is correctly mapped to
      /// Flutter's Curves.linear constant instead of a string literal.
      test('Motion Token - CSS Linear', () {
        String input = "linear";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.linear"));
        expect(result, isNot(contains("'linear'")));
      });

      /// Tests that unrecognized easing values fallback to valid Curve instances
      ///
      /// Verifies that unrecognized easing values are mapped to a valid Flutter
      /// Curve (Curves.linear) instead of invalid string literals, preventing
      /// the generation of invalid Dart code.
      test('Motion Token - Unrecognized Fallback', () {
        String input = "unknown-easing";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.linear"));
        expect(result,
            contains("fallback for unrecognized easing: unknown-easing"));
        expect(result, isNot(contains("'unknown-easing'")));
      });

      /// Tests that step-start values are handled appropriately
      ///
      /// Verifies that CSS step-start values are approximated with a valid
      /// Flutter Curve instead of being left as string literals.
      test('Motion Token - Step Start', () {
        String input = "step-start";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.linear"));
        expect(result, contains("step-start approximated as linear"));
        expect(result, isNot(contains("'step-start'")));
      });

      /// Tests that step-end values are handled appropriately
      ///
      /// Verifies that CSS step-end values are approximated with a valid
      /// Flutter Curve instead of being left as string literals.
      test('Motion Token - Step End', () {
        String input = "step-end";
        String result = TokenFormatterFactory.getFormatter('motion')
            .format(input, DesignTokenUtils.categoryCore);
        expect(result, contains("Curves.linear"));
        expect(result, contains("step-end approximated as linear"));
        expect(result, isNot(contains("'step-end'")));
      });
    });

    /// Tests for token name conversion
    ///
    /// These tests verify that dot-notation token references are correctly converted
    /// to camelCase Dart property names for different token categories and contexts.
    group('Token Name Conversion Tests', () {
      /// Tests conversion of core token names in core category context
      ///
      /// Verifies that dot-notation core token references are correctly converted
      /// to camelCase property names when used in the core category.
      test('Core Token in Core Category', () {
        String input = "core.color.solid.magenta.700";
        String result = DesignTokenUtils.convertToDartPropertyName(
            input, DesignTokenUtils.categoryCore);
        expect(result, equals("coreColorSolidMagenta700"));
      });

      /// Tests conversion of core token names in light category context
      ///
      /// Verifies that core token references are correctly prefixed with
      /// CoreDesignTokens when used in the light category.
      test('Core Token in Light Category', () {
        String input = "core.color.solid.magenta.700";
        String result = DesignTokenUtils.convertToDartPropertyName(
            input, DesignTokenUtils.categoryLight);
        expect(result, equals("CoreDesignTokens.coreColorSolidMagenta700"));
      });

      /// Tests conversion of light theme token names
      ///
      /// Verifies that light theme token references are correctly converted to
      /// camelCase property names without the "light" prefix.
      test('Light Token in Light Category', () {
        String input = "light.background.primary";
        String result = DesignTokenUtils.convertToDartPropertyName(
            input, DesignTokenUtils.categoryLight);
        expect(result, equals("backgroundPrimary"));
      });

      /// Tests handling of numeric parts in token names
      ///
      /// Verifies that token references with numeric parts (like "730") are
      /// correctly preserved in the camelCase property name.
      test('Numeric Token Part', () {
        String input = "core.elevation.shadow.730";
        String result = DesignTokenUtils.convertToDartPropertyName(
            input, DesignTokenUtils.categoryCore);
        expect(result, equals("coreElevationShadow730"));
      });
    });

    /// Tests for the formatter factory
    ///
    /// These tests verify that the TokenFormatterFactory correctly returns the
    /// appropriate formatter for different token types, and that the default formatter
    /// handles unknown types correctly.
    group('Formatter Factory Tests', () {
      /// Tests retrieval of color formatter
      ///
      /// Verifies that the TokenFormatterFactory correctly returns a ColorTokenFormatter
      /// when requesting a formatter for the 'color' token type.
      test('Get Color Formatter', () {
        var formatter = TokenFormatterFactory.getFormatter('color');
        expect(formatter, isA<ColorTokenFormatter>());
      });

      /// Tests retrieval of box shadow formatter
      ///
      /// Verifies that the TokenFormatterFactory correctly returns a BoxShadowTokenFormatter
      /// when requesting a formatter for the 'boxShadow' token type.
      test('Get Box Shadow Formatter', () {
        var formatter = TokenFormatterFactory.getFormatter('boxShadow');
        expect(formatter, isA<BoxShadowTokenFormatter>());
      });

      /// Tests fallback to default formatter for unknown token types
      ///
      /// Verifies that the TokenFormatterFactory returns a default formatter
      /// when requesting a formatter for an unknown token type, and that the
      /// default formatter correctly handles simple string values.
      test('Get Default Formatter for Unknown Type', () {
        var formatter = TokenFormatterFactory.getFormatter('unknown');
        // Instead of checking the specific type (which is private),
        // verify the behavior of the default formatter
        String result = formatter.format('test', DesignTokenUtils.categoryCore);
        expect(result, equals("'test'"));
      });
    });
  });
}
