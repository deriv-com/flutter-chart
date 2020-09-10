import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

typedef EpochToX = double Function(int);
typedef QuoteToY = double Function(double);

/// Any component that the chart takes and makes it paint its self on the chart's canvas
abstract class Component {
  /// The ID of this [Component]
  String id;

  /// Will be called by the chart when the it was updated.
  void didUpdateSeries(Component oldComponent);

  /// Updates this [Component] after tye chart's epoch boundaries changes.
  void update(int leftEpoch, int rightEpoch);

  /// The minimum value this [Component] has at the current x-axis epoch range after [update] is called.
  ///
  /// [double.nan] should be returned if this component doesn't have any element to have a minimum value.
  double get minValue;

  /// The maximum value this [Component] has at the current x-axis epoch range after [update] is called.
  ///
  /// /// [double.nan] should be returned if this component doesn't have any element to have a maximum value.
  double get maxValue;

  /// Paints this [Component]'s on the passed [canvas].
  ///
  /// [Size] is the size of the [canvas].
  ///
  /// [epochToX] is the conversion function to convert epoch to canvas X.
  ///
  /// [quoteToY] is the conversion function to convert quote to canvas Y.
  ///
  /// [animationInfo] Contains animations progress value in this frame of painting.
  ///
  /// [pipSize] Number of decimal digits components must use on showing their values.
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
  );
}
