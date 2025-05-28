import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/ohlc_series_crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/highlight/crosshair_candle_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/highlight/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/strategy/crosshair_strategy_context.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

import '../../data_series.dart';
import '../../series_painter.dart';
import '../ohlc_type_series.dart';
import 'candle_painter.dart';

/// CandleStick series
class CandleSeries extends OHLCTypeSeries {
  /// Initializes
  CandleSeries(
    List<Candle> entries, {
    String? id,
    CandleStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id ?? 'CandleSeries',
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  SeriesPainter<DataSeries<Candle>> createPainter() => CandlePainter(this);

  /// Returns a CrosshairHighlightPainter for highlighting a candle at the crosshair position.
  ///
  /// This implementation creates a CrosshairCandleHighlightPainter that draws a highlighted
  /// version of the candle at the crosshair position. The candle is drawn with special
  /// "active" colors to distinguish it from regular candles.
  ///
  /// The candle width is calculated dynamically based on the chart's granularity and
  /// the xFromEpoch function, which ensures the candle's visual width is appropriate
  /// for the current chart zoom level and time scale.
  ///
  /// Parameters:
  /// * [crosshairTick] - The candle data to highlight at the crosshair position.
  /// * [quoteToY] - Function that converts a price quote to a Y-coordinate on the canvas.
  /// * [xCenter] - The X-coordinate center position where the candle should be drawn.
  /// * [granularity] - The time granularity of the chart in seconds.
  /// * [xFromEpoch] - Function that converts a timestamp to an X-coordinate on the canvas.
  /// * [theme] - The chart theme containing colors for the highlighted candle.
  ///
  /// Returns:
  /// A CrosshairCandleHighlightPainter that will paint the highlighted candle.
  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
    Candle crosshairTick,
    double Function(double) quoteToY,
    double xCenter,
    int granularity,
    ChartTheme theme,
    double Function(int) xFromEpoch,
  ) {
    // Check if the current candle is bullish or bearish.
    // Bullish means price went up (close > open)
    final bool isBullishCandle = crosshairTick.close > crosshairTick.open;

    // Calculate candle width based on granularity
    // This calculation determines how wide each candle should be drawn on the chart
    //
    // xFromEpoch is a function that converts a timestamp to an X-coordinate on the canvas
    // xFromEpoch(granularity) gives the X-coordinate for a point that is 'granularity' seconds from epoch start
    // xFromEpoch(0) gives the X-coordinate for the epoch start (January 1, 1970)
    //
    // The difference between these two coordinates gives us the width in pixels that
    // corresponds to one 'granularity' interval on the chart (e.g., the width of a 1-minute period)
    //
    // We multiply by 0.6 (60%) to make the candle width 60% of the full interval width,
    // leaving some space between candles for better readability
    final double candleWidth = (xFromEpoch(granularity) - xFromEpoch(0)) * 0.6;

    return CrosshairCandleHighlightPainter(
      candle: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      candleWidth: candleWidth,
      bodyHighlightColor: isBullishCandle
          ? theme.candleBullishBodyActive
          : theme.candleBearishBodyActive,
      wickHighlightColor: isBullishCandle
          ? theme.candleBullishWickActive
          : theme.candleBearishWickActive,
    );
  }

  @override
  CrosshairStrategyContext<Candle> getCrosshairStrategyContext() {
    return CrosshairStrategyContext<Candle>(
      smallScreenBehaviourBuilder: () =>
          OHLCSeriesSmallScreenBehaviour<Candle>(),
      largeScreenBehaviourBuilder: () =>
          OHLCSeriesLargeScreenBehaviour<Candle>(),
    );
  }
}
