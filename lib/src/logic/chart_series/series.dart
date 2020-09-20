import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Base class of all chart series
abstract class Series implements ChartData {
  /// Initializes
  Series(this.id, {this.style}) {
    seriesPainter = createPainter();
    this.id ??= '$runtimeType${style.runtimeType}${seriesPainter.runtimeType}';
  }

  @override
  String id;

  /// Responsible for painting a frame of this series on the canvas.
  @protected
  SeriesPainter<Series> seriesPainter;

  /// The painting style of this [Series]
  final ChartPaintingStyle style;

  /// Minimum value of this series in a visible range of the chart
  @protected
  double minValueInFrame;

  /// Maximum value of this series in a visible range of the chart
  @protected
  double maxValueInFrame;

  /// Min quote in a frame
  @override
  double get minValue => minValueInFrame ?? double.nan;

  /// Max quote in a frame
  @override
  double get maxValue => maxValueInFrame ?? double.nan;

  /// Updates visible entries for this Series.
  @override
  void update(int leftEpoch, int rightEpoch) {
    onUpdate(leftEpoch, rightEpoch);

    final List<double> minMaxValues = recalculateMinMax();

    minValueInFrame = minMaxValues[0];
    maxValueInFrame = minMaxValues[1];
  }

  /// Calculate min/max values in updated data
  List<double> recalculateMinMax();

  /// Updates series visible data
  void onUpdate(int leftEpoch, int rightEpoch);

  /// Is called whenever series is created to create its [seriesPainter] as well.
  SeriesPainter<Series> createPainter();

  /// Paints [seriesPainter]'s data on the [canvas]
  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  ) =>
      seriesPainter?.paint(
        canvas: canvas,
        size: size,
        epochToX: epochToX,
        quoteToY: quoteToY,
        animationInfo: animationInfo,
        pipSize: pipSize,
        granularity: granularity,
      );
}
