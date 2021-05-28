import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Base class of chart annotations.
abstract class ChartAnnotation<T extends ChartObject> extends Series {
  /// Initializes a base class of chart annotations.
  ChartAnnotation(
    String id, {
    ChartPaintingStyle? style,
  }) : super(id, style: style) {
    annotationObject = createObject();
  }

  /// Annotation Object.
  late T annotationObject;

  /// Previous annotation object.
  T? previousObject;

  /// Is this [ChartAnnotation] on the chart's epoch range.
  bool isOnRange = false;

  bool _shouldRepaint = false;

  @override
  bool didUpdate(ChartData? oldData) {
    final ChartAnnotation<T>? oldAnnotation = oldData as ChartAnnotation<T>?;

    if (annotationObject == oldAnnotation?.annotationObject) {
      previousObject = oldAnnotation?.previousObject;
      _shouldRepaint = false;
    } else {
      previousObject = oldAnnotation?.annotationObject;
      _shouldRepaint = true;
    }
    return _shouldRepaint;
  }

  @override
  bool shouldRepaint(ChartData? previous) {
    final ChartAnnotation<T>? previousAnnotation =
        previous as ChartAnnotation<T>?;
    if (isOnRange || isOnRange != previousAnnotation!.isOnRange) {
      return _shouldRepaint;
    }
    return false;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
  ) {
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // Prevent re-animating annotation that haven't changed.
    if (animationInfo.currentTickPercent == 1) {
      previousObject = null;
    }
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      isOnRange = annotationObject.isOnEpochRange(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() => <double>[
        annotationObject.bottomValue ?? double.nan,
        annotationObject.topValue ?? double.nan
      ];

  /// Prepares the [annotationObject] of this [ChartAnnotation].
  T createObject();
}
