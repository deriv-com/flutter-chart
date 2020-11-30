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
    this.dataSeries,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
    this.rightBoundEpoch,
    this.leftBoundEpoch,
    this.topY,
  });

  /// Chart config
  final ChartConfig chartConfig;

  final ChartTheme theme;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  final DataSeries dataSeries;

  /*
  For detecting a need of repaint:
  */

  final int rightBoundEpoch;

  final int leftBoundEpoch;

  /// Tracking topY change is sufficient, since top and bottom padding are equal.
  final double topY;

  @override
  void paint(Canvas canvas, Size size) {
    dataSeries.paint(
      canvas,
      size,
      epochToCanvasX,
      quoteToCanvasY,
      animationInfo,
      chartConfig,
      theme,
    );
  }

  @override
  bool shouldRepaint(ChartDataPainter oldDelegate) {
    bool styleChanged() =>
        (dataSeries is LineSeries &&
            theme.lineStyle != oldDelegate.theme.lineStyle) ||
        (dataSeries is CandleSeries &&
            theme.candleStyle != oldDelegate.theme.candleStyle);

    bool visibleAnimationChanged() =>
        dataSeries.entries.isNotEmpty &&
        dataSeries.visibleEntries.isNotEmpty &&
        dataSeries.entries.last == dataSeries.visibleEntries.last &&
        animationInfo != oldDelegate.animationInfo;

    return rightBoundEpoch != oldDelegate.rightBoundEpoch ||
        leftBoundEpoch != oldDelegate.leftBoundEpoch ||
        topY != oldDelegate.topY ||
        visibleAnimationChanged() ||
        chartConfig != oldDelegate.chartConfig ||
        styleChanged();
  }

  @override
  bool shouldRebuildSemantics(ChartDataPainter oldDelegate) => false;
}
