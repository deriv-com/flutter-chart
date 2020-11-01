import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';

/// Indicates the chart's data painting style, including whether its line, candle, etc
/// and their respective colors and dimensions.
abstract class DataSeriesStyle extends ChartPaintingStyle {
  /// Abstract const constructor.
  /// This constructor enables subclasses to provide const constructors.
  const DataSeriesStyle({this.lastTickStyle});

  /// Current tick style
  ///
  /// If set, an indicator for the current tick of the series will be shown.
  final HorizontalBarrierStyle lastTickStyle;
}
