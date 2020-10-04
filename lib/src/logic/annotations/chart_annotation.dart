import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:flutter/cupertino.dart';

abstract class ChartAnnotation<T extends ChartObject> extends ChartData {
  ChartAnnotation(String id) : super(id) {
    this.id ??= '$runtimeType';
  }

  /// Annotation Object
  @protected
  T annotationObject;

  @protected
  T preChartObject;

  @protected
  bool isOnRange = false;

  @override
  void didUpdate(ChartData oldData) {
    final ChartAnnotation oldAnnotation = oldData;

    preChartObject = oldAnnotation.annotationObject;
  }

  @override
  void update(int leftEpoch, int rightEpoch) {
    isOnRange = annotationObject.isOnRange(leftEpoch, rightEpoch);

    if (!annotationObject.topValue.isNaN) {
      maxValueInFrame = annotationObject.topValue;
    }

    if (!annotationObject.bottomValue.isNaN) {
      minValueInFrame = annotationObject.bottomValue;
    }
  }
}
