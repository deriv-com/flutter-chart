import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../deriv_chart.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.chartConfig,
    this.theme,
    this.chartDataList,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
    this.rightEpoch,
    this.leftEpoch,
  });

  /// Chart config
  final ChartConfig chartConfig;

  final ChartTheme theme;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  final List<ChartData> chartDataList;

  final int rightEpoch;
  final int leftEpoch;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ChartData c in chartDataList) {
      c.paint(
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
  bool shouldRepaint(ChartPainter oldDelegate) {
    for (final ChartData c in chartDataList) {
      if (c.shouldRepaint()) {
        return true;
      }
    }
    if (rightEpoch != oldDelegate.rightEpoch ||
        leftEpoch != oldDelegate.leftEpoch) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
