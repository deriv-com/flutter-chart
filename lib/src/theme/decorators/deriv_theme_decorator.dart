import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

/// A decorator that applies the Deriv brand theme to a chart.
///
/// This decorator follows the Decorator design pattern, extending the base
/// [ChartThemeDecorator] to customize specific aspects of the chart's appearance
/// with Deriv brand-specific styling while inheriting all other properties from the
/// base theme.
///
/// The Deriv theme is characterized by its coral color scheme, particularly
/// using [DerivThemeColors] for styling chart elements, which aligns with
/// the Deriv brand identity.
class DerivThemeDecorator extends ChartThemeDecorator {
  /// Creates a new [DerivThemeDecorator] with the specified base theme.
  ///
  /// The [baseTheme] provides the default styling for all chart elements,
  /// which this decorator will selectively override with Deriv brand-specific styling.
  DerivThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  /// Overrides the area line style with Deriv brand-specific styling.
  ///
  /// This style is used for area charts and includes:
  /// - A coral line color using [DerivThemeColors.areaDerivLine]
  /// - Area fill enabled with a gradient from semi-transparent to transparent coral
  @override
  LineStyle get areaLineStyle => const LineStyle(
          color: DerivThemeColors.areaDerivLine,
          hasArea: true,
          areaGradientColors: (
            start: DerivThemeColors.areaDerivGradientStart,
            end: DerivThemeColors.areaDerivGradientEnd,
          ));

  /// Overrides the current spot indicator style with Deriv brand-specific styling.
  ///
  /// This style is used for the horizontal line that indicates the current spot price:
  /// - Uses [DerivThemeColors.currentSpotDerivContainer] for the line and container
  /// - Applies a custom text style with [DerivThemeColors.currentSpotDerivLabel] color
  /// - Uses a solid line (not dashed)
  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
        color: DerivThemeColors.currentSpotDerivContainer,
        textStyle: textStyle(
            textStyle: currentSpotLabelText,
            color: DerivThemeColors.currentSpotDerivLabel),
        isDashed: false,
      );
}
