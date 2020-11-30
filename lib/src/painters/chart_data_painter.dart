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
    print('>>> paint');
  }

  @override
  bool shouldRepaint(ChartDataPainter oldDelegate) {
    bool styleChanged() =>
        (dataSeries is LineSeries &&
            theme.lineStyle != oldDelegate.theme.lineStyle) ||
        (dataSeries is CandleSeries &&
            theme.candleStyle != oldDelegate.theme.candleStyle);

    bool repaint = rightBoundEpoch != oldDelegate.rightBoundEpoch ||
        leftBoundEpoch != oldDelegate.leftBoundEpoch ||
        chartConfig != oldDelegate.chartConfig ||
        epochToCanvasX != oldDelegate.epochToCanvasX ||
        quoteToCanvasY != oldDelegate.quoteToCanvasY ||
        styleChanged();

    if (repaint) {
      print(
          '>>> repaint ${chartConfig != oldDelegate.chartConfig ? 'config' : ''} ${styleChanged() ? 'style' : ''} ${epochToCanvasX != oldDelegate.epochToCanvasX ? 'e' : ''} ${quoteToCanvasY != oldDelegate.quoteToCanvasY ? 'e' : ''} ${visibleEntriesChanged() ? 'visibleEntries' : ''}');
    }

    return repaint;
  }

  @override
  bool shouldRebuildSemantics(ChartDataPainter oldDelegate) => false;
}
