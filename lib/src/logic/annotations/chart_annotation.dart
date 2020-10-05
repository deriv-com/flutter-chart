import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:flutter/material.dart';

abstract class ChartAnnotation<T extends ChartObject> extends Series {
  ChartAnnotation(String id) : super(id);

  /// Annotation Object
  T annotationObject;

  T previousObject;

  bool isOnRange = false;

  @override
  void didUpdate(ChartData oldData) {
    final ChartAnnotation oldAnnotation = oldData;

    previousObject = oldAnnotation.annotationObject;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      isOnRange = annotationObject.isOnRange(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() =>
      <double>[annotationObject.bottomValue, annotationObject.topValue];
}
