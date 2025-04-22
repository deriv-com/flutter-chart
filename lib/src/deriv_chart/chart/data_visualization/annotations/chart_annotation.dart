import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_object.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';

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

  @override
  bool didUpdate(ChartData? oldData) {
    final ChartAnnotation<T>? oldAnnotation = oldData as ChartAnnotation<T>?;
    late final bool updated;

    if (annotationObject == oldAnnotation?.annotationObject) {
      previousObject = oldAnnotation?.previousObject;
      updated = false;
    } else {
      previousObject = oldAnnotation?.annotationObject;
      updated = true;
    }

    return updated;
  }

  // TODO(Ramin): should repaint logic should be based on whether the annotation
  //  is on range and also if the scroll position has changed
  // Right now we're making decision based on if it's in range or not.
  // Should add a way to check for view port range change as well.
  @override
  bool shouldRepaint(ChartData? previous) {
    final ChartAnnotation<T>? previousAnnotation =
        previous as ChartAnnotation<T>?;
    if (isOnRange || isOnRange != previousAnnotation!.isOnRange) {
      return true;
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
    ChartScaleModel chartScaleModel,
  ) {
    super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
        theme, chartScaleModel);

    // Prevent re-animating annotation that haven't changed.
    if (animationInfo.currentTickPercent == 1) {
      previousObject = null;
    }
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      isOnRange = annotationObject.isOnEpochRange(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() => isOnRange
      ? <double>[
          annotationObject.bottomValue ?? double.nan,
          annotationObject.topValue ?? double.nan
        ]
      : <double>[double.nan, double.nan];

  /// Prepares the [annotationObject] of this [ChartAnnotation].
  T createObject();
}
