import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';

/// Base class of chart annotations
abstract class ChartAnnotation<T extends ChartObject> extends Series {
  /// Initializes
  ChartAnnotation(
    String id, {
    ChartPaintingStyle style,
  }) : super(id, style: style) {
    annotationObject = createObject();
  }

  /// Annotation Object
  T annotationObject;

  /// Previous annotation object
  T previousObject;

  /// Is this [ChartAnnotation] on the chart's epoch range
  bool isOnRange = false;

  bool _shouldrepaint = false;

  @override
  bool didUpdate(ChartData oldData) {
    final ChartAnnotation<T> oldAnnotation = oldData;

    // Reuse `isOnRange` value if visible area didn't change.
    isOnRange = oldAnnotation.isOnRange;

    if (annotationObject == oldAnnotation?.annotationObject ?? false) {
      previousObject = oldAnnotation?.previousObject;
      _shouldrepaint = false;
    } else {
      previousObject = oldAnnotation?.annotationObject;
      _shouldrepaint = true;
    }
    return _shouldrepaint;
  }

  @override
  bool shouldRepaint(ChartData previous) {
    final ChartAnnotation<T> previousAnnotation = previous;
    if (isOnRange || isOnRange != previousAnnotation.isOnRange) {
      return _shouldrepaint;
    }
    return false;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      isOnRange = annotationObject.isOnEpochRange(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() =>
      <double>[annotationObject.bottomValue, annotationObject.topValue];

  /// Prepares the [annotationObject] of this [ChartAnnotation]
  T createObject();
}
