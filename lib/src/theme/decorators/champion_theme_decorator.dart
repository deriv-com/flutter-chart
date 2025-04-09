import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

/// A decorator that applies the Champion theme to a chart.
///
/// This decorator follows the Decorator design pattern, extending the base
/// [ChartThemeDecorator] to customize specific aspects of the chart's appearance
/// with Champion-specific styling while inheriting all other properties from the
/// base theme.
///
/// The Champion theme is characterized by its blue color scheme, particularly
/// using [ChampionThemeColors] for styling chart elements.
class ChampionThemeDecorator extends ChartThemeDecorator {
  /// Creates a new [ChampionThemeDecorator] with the specified base theme.
  ///
  /// The [baseTheme] provides the default styling for all chart elements,
  /// which this decorator will selectively override with Champion-specific styling.
  ChampionThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  /// Overrides the area line style with Champion theme-specific styling.
  ///
  /// This style is used for area charts and includes:
  /// - A blue line color using [ChampionThemeColors.areaChampionLine]
  /// - Area fill enabled with a gradient from semi-transparent to transparent blue
  @override
  LineStyle get areaLineStyle => const LineStyle(
          color: ChampionThemeColors.areaChampionLine,
          hasArea: true,
          areaGradientColors: (
            start: ChampionThemeColors.areaChampionGradientStart,
            end: ChampionThemeColors.areaChampionGradientEnd,
          ));

  /// Overrides the current spot indicator style with Champion theme-specific styling.
  ///
  /// This style is used for the horizontal line that indicates the current spot price:
  /// - Uses [ChampionThemeColors.currentSpotChampionContainer] for the line and container
  /// - Applies a custom text style with [ChampionThemeColors.currentSpotChampionLabel] color
  /// - Uses a solid line (not dashed)
  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
        color: ChampionThemeColors.currentSpotChampionContainer,
        textStyle: textStyle(
            textStyle: currentSpotLabelText,
            color: ChampionThemeColors.currentSpotChampionLabel),
        isDashed: false,
      );
}
