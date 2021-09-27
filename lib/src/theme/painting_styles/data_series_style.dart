import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';

/// Indicates the chart's data painting style, including whether its line,
/// candle, etc and their respective colors and dimensions.
abstract class DataSeriesStyle extends ChartPaintingStyle {
  /// Provides const constructor for sub-classes.
  const DataSeriesStyle();
}
