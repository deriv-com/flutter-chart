import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

class ChartDataPainter extends CustomPainter {
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

  /// Chart config
  final ChartConfig chartConfig;

  final ChartTheme theme;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  final DataSeries mainSeries;
  final List<Series> secondarySeries;

  /*
  For detecting a need of repaint:
  */

  final int rightBoundEpoch;

  final int leftBoundEpoch;

  final double topY;

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
        styleChanged();
  }

  @override
  bool shouldRebuildSemantics(ChartDataPainter oldDelegate) => false;
}
