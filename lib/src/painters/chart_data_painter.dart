import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// A `CustomPainter` which paints the chart data inside the chart.
class ChartDataPainter extends CustomPainter {
  /// Initializes a `CustomPainter` which paints the chart data inside the chart.
  ChartDataPainter({
    this.chartConfig,
    this.theme,
    this.mainSeries,
    this.secondarySeries = const <Series>[],
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

  /// Chart's main data series.
  final DataSeries mainSeries;

  /// List of series to add on chart beside the [mainSeries].
  ///
  /// Useful for adding on-chart indicators.
  final List<Series> secondarySeries;

  /*
  For detecting a need of repaint:
  */

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
    mainSeries.paint(
      canvas,
      size,
      epochToCanvasX,
      quoteToCanvasY,
      animationInfo,
      chartConfig,
      theme,
    );

    if (secondarySeries == null) {
      return;
    }

    for (final Series series in secondarySeries) {
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
  bool shouldRepaint(ChartDataPainter oldDelegate) {
    bool styleChanged() =>
        (mainSeries is LineSeries &&
            theme.lineStyle != oldDelegate.theme.lineStyle) ||
        (mainSeries is CandleSeries &&
            theme.candleStyle != oldDelegate.theme.candleStyle);

    bool secondarySeriesChanged() {
      final bool isNull = secondarySeries == null;
      final bool wasNull = oldDelegate.secondarySeries == null;

      if (isNull && wasNull) {
        return false;
      } else if (isNull != wasNull) {
        return true;
      } else if (secondarySeries.length != oldDelegate.secondarySeries.length) {
        return true;
      }

      final Map<String, ChartPaintingStyle> oldStyles =
          Map<String, ChartPaintingStyle>.fromIterable(
        oldDelegate.secondarySeries,
        key: (dynamic series) => series.id,
        value: (dynamic series) => series.style,
      );
      return secondarySeries.any(
        (Series series) => series.style != oldStyles[series.id],
      );
    }

    bool visibleAnimationChanged() =>
        mainSeries.entries.isNotEmpty &&
        mainSeries.visibleEntries.isNotEmpty &&
        mainSeries.entries.last == mainSeries.visibleEntries.last &&
        animationInfo != oldDelegate.animationInfo;

    return rightBoundEpoch != oldDelegate.rightBoundEpoch ||
        leftBoundEpoch != oldDelegate.leftBoundEpoch ||
        topY != oldDelegate.topY ||
        bottomY != oldDelegate.bottomY ||
        visibleAnimationChanged() ||
        chartConfig != oldDelegate.chartConfig ||
        mainSeries.runtimeType != oldDelegate.mainSeries.runtimeType ||
        styleChanged() ||
        secondarySeriesChanged();
  }

  @override
  bool shouldRebuildSemantics(ChartDataPainter oldDelegate) => false;
}
