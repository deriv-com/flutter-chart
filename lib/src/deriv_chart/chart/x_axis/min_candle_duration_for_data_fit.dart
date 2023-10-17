import 'x_axis_model.dart';

/// Minimum candle duration with which [entriesDuration] can fit into available
/// width in data fit mode.
///
/// This function is meant for external usage, to choose initial granularity for
/// contract details.
///
/// Default scale is used.
/// Default scale means each interval (in other words candle) is
/// [XAxisModel.defaultIntervalWidth] pixels in width.
///
/// [entriesDuration] is a total duration of all entries.
/// [chartWidth] is pixel width of the chart widget.
Duration minCandleDurationForDataFit(
  Duration entriesDuration,
  double chartWidth,
) {
  final double availableWidth = chartWidth - dataFitPadding.horizontal;
  final double msPerPx = entriesDuration.inMilliseconds / availableWidth;
  return Duration(
    milliseconds: (msPerPx * XAxisModel.defaultIntervalWidth).ceil(),
  );
}
