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
    this.chartData,
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

  final ChartData chartData;

  final int rightEpoch;
  final int leftEpoch;

  @override
  void paint(Canvas canvas, Size size) {
    chartData.paint(
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
  bool shouldRepaint(ChartPainter oldDelegate) =>
      chartData.shouldRepaint(oldDelegate.chartData);

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
