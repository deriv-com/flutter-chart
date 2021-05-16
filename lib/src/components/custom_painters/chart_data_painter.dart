import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/line_series/line_series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/ohlc_series/candle/candle_series.dart';
import 'package:deriv_chart/src/components/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// A `CustomPainter` which paints the chart data inside the chart.
class ChartDataPainter extends BaseChartDataPainter {
  /// Initializes a `CustomPainter` which paints the chart data inside the chart.
  ChartDataPainter({
    ChartConfig chartConfig,
    ChartTheme theme,
    this.mainSeries,
    List<Series> secondarySeries = const <Series>[],
    AnimationInfo animationInfo,
    EpochToX epochToCanvasX,
    QuoteToY quoteToCanvasY,
    int rightBoundEpoch,
    int leftBoundEpoch,
    double topY,
    double bottomY,
  }) : super(
          chartConfig: chartConfig,
          theme: theme,
          series: secondarySeries,
          animationInfo: animationInfo,
          epochToCanvasX: epochToCanvasX,
          quoteToCanvasY: quoteToCanvasY,
          rightBoundEpoch: rightBoundEpoch,
          leftBoundEpoch: leftBoundEpoch,
          topY: topY,
          bottomY: bottomY,
        );

  /// Chart's main data series.
  final Series mainSeries;

  @override
  void paint(Canvas canvas, Size size) {
    mainSeries.paint(
      canvas,
      size,
      epochToCanvasX,
      quoteToCanvasY,
      animationInfo,
      chartConfig,
      theme,
    );

    super.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ChartDataPainter oldDelegate) {
    bool styleChanged() =>
        (mainSeries is LineSeries && oldDelegate.mainSeries is CandleSeries) ||
        (mainSeries is CandleSeries && oldDelegate.mainSeries is LineSeries) ||
        (mainSeries is LineSeries &&
            theme.lineStyle != oldDelegate.theme.lineStyle) ||
        (mainSeries is CandleSeries &&
            theme.candleStyle != oldDelegate.theme.candleStyle);

    bool visibleAnimationChanged() =>
        mainSeries.shouldRepaint(oldDelegate.mainSeries);

    return super.shouldRepaint(oldDelegate) ||
        visibleAnimationChanged() ||
        styleChanged();
  }
}

/// A `CustomPainter` which paints the chart data inside the chart.
class BaseChartDataPainter extends CustomPainter {
  /// Initializes a `CustomPainter` which paints the chart data inside the chart.
  BaseChartDataPainter({
    this.chartConfig,
    this.theme,
    this.series = const <Series>[],
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
    this.rightBoundEpoch,
    this.leftBoundEpoch,
    this.topY,
    this.bottomY,
  });

  /// Chart config.
  final ChartConfig chartConfig;

  /// The theme used to paint the chart data.
  final ChartTheme theme;

  /// Conversion function for converting epoch to chart's canvas' X position.
  final double Function(int) epochToCanvasX;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Animation info where the animation progress values are in.
  final AnimationInfo animationInfo;

  /// Series classes to paint
  final List<Series> series;

  /// The right bound epoch of a chart.
  final int rightBoundEpoch;

  /// The left bound epoch of a chart.
  final int leftBoundEpoch;

  /// Top part of the chart in the y axis.
  final double topY;

  /// Bottom part of the chart in the y axis.
  final double bottomY;

  @override
  void paint(Canvas canvas, Size size) {
    if (series == null) {
      return;
    }

    for (final Series series in series) {
      series.paint(
        canvas,
        size,
        epochToCanvasX,
        quoteToCanvasY,
        animationInfo,
        chartConfig,
        theme,
      );
    }
  }

  @override
  bool shouldRepaint(BaseChartDataPainter oldDelegate) {
    bool seriesChanged() {
      final bool isNull = series == null;
      final bool wasNull = oldDelegate.series == null;

      if (isNull && wasNull) {
        return false;
      } else if (isNull != wasNull) {
        return true;
      } else if (series.length != oldDelegate.series.length) {
        return true;
      }

      final Map<String, ChartPaintingStyle> oldStyles =
          Map<String, ChartPaintingStyle>.fromIterable(
        oldDelegate.series,
        key: (dynamic series) => series.id,
        value: (dynamic series) => series.style,
      );
      return series.any(
        (Series series) => series.style != oldStyles[series.id],
      );
    }

    return rightBoundEpoch != oldDelegate.rightBoundEpoch ||
        leftBoundEpoch != oldDelegate.leftBoundEpoch ||
        topY != oldDelegate.topY ||
        bottomY != oldDelegate.bottomY ||
        chartConfig != oldDelegate.chartConfig ||
        seriesChanged();
  }
}
