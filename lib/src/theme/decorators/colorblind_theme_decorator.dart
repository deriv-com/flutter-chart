import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/decorators/chart_theme_decorator.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

/// A decorator that applies colorblind-friendly styling to chart elements.
///
/// This decorator follows the Decorator design pattern, extending the base
/// [ChartThemeDecorator] to customize specific aspects of the chart's appearance
/// with colors that are more distinguishable for users with color vision deficiencies,
/// while inheriting all other properties from the base theme.
///
/// The colorblind theme specifically modifies the candlestick chart colors to use
/// a blue and yellow color scheme instead of the traditional green and red, which
/// can be difficult to distinguish for people with red-green color blindness
/// (the most common type of color vision deficiency).
class ColorblindThemeDecorator extends ChartThemeDecorator {
  /// Creates a new [ColorblindThemeDecorator] with the specified base theme.
  ///
  /// The [baseTheme] provides the default styling for all chart elements,
  /// which this decorator will selectively override with colorblind-friendly styling.
  ColorblindThemeDecorator(ChartTheme baseTheme) : super(baseTheme);

  /// Overrides the candle style with colorblind-friendly colors.
  ///
  /// This style is used for candlestick charts and modifies:
  /// - Bullish candle body and wick colors to blue shades
  ///   ([CandleBullishThemeColors.candleBullishBodyColorBlind] and
  ///   [CandleBullishThemeColors.candleBullishWickColorBlind])
  /// - Bearish candle body and wick colors to yellow shades
  ///   ([CandleBearishThemeColors.candleBearishBodyColorBlind] and
  ///   [CandleBearishThemeColors.candleBearishWickColorBlind])
  ///
  /// These color choices provide better contrast and distinguishability for
  /// users with color vision deficiencies, particularly those with
  /// red-green color blindness (deuteranopia or protanopia).
  @override
  CandleStyle get candleStyle => const CandleStyle(
      candleBullishBodyColor:
          CandleBullishThemeColors.candleBullishBodyColorBlind,
      candleBearishBodyColor:
          CandleBearishThemeColors.candleBearishBodyColorBlind,
      candleBullishWickColor:
          CandleBullishThemeColors.candleBullishWickColorBlind,
      candleBearishWickColor:
          CandleBearishThemeColors.candleBearishWickColorBlind);
}
