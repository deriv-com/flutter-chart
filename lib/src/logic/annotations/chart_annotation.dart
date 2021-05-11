import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';

/// Base class of chart annotations.
abstract class ChartAnnotation<T extends ChartObject> extends Series {
  /// Initializes a base class of chart annotations.
  ChartAnnotation(
    String id, {
    ChartPaintingStyle style,
  }) : super(id, style: style) {
    annotationObject = createObject();
  }

  /// Annotation Object.
  T annotationObject;

  /// Previous annotation object.
  T previousObject;

  /// Is this [ChartAnnotation] on the chart's epoch range.
  bool isOnRange = false;

  bool _shouldRepaint = false;

  @override
  bool didUpdate(ChartData oldData) {
    final ChartAnnotation<T> oldAnnotation = oldData;

    // This if condition was to avoid breaking anootation animation.
    // A temporarily workaround to find a better solution later.
    // if (annotationObject == oldAnnotation?.annotationObject ?? false) {
    //   previousObject = oldAnnotation?.previousObject;
    //   _shouldRepaint = false;
    // } else {
    //
    previousObject = oldAnnotation?.annotationObject;
    // }
    return _shouldRepaint = true;
  }

  @override
  bool shouldRepaint(ChartData previous) {
    final ChartAnnotation<T> previousAnnotation = previous;
    if (isOnRange || isOnRange != previousAnnotation.isOnRange) {
      return _shouldRepaint;
    }
    return false;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      isOnRange = annotationObject.isOnEpochRange(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() =>
      <double>[annotationObject.bottomValue, annotationObject.topValue];

  /// Prepares the [annotationObject] of this [ChartAnnotation].
  T createObject();
}
