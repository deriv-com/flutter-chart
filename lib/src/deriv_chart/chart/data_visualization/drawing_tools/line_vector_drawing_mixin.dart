import 'package:deriv_chart/src/add_ons/drawing_tools_ui/distance_constants.dart';

import 'data_model/vector.dart';

/// Mixin to calculate the vector of a line and related functionalities which
/// a drawing tool with a line should have.
mixin LineVectorDrawingMixin {
  /// Gets the vector of a line which is defined by two points. (4 values)
  ///
  /// If [exceedStart] is true, the vector line will be extended further than
  /// the start coordinates. Same thing is there for [exceedEnd] and end
  /// coordinates.
  Vector getLineVector(
    double startXCoord,
    double startYCoord,
    double endXCoord,
    double endYCoord, {
    bool exceedStart = false,
    bool exceedEnd = false,
  }) {
    Vector vec = Vector(
      x0: startXCoord,
      y0: startYCoord,
      x1: endXCoord,
      y1: endYCoord,
    );

    late double earlier, later;
    if (exceedEnd && !exceedStart) {
      earlier = vec.x0;
      if (vec.x0 > vec.x1) {
        later = vec.x1 - DrawingToolDistance.horizontalDistance;
      } else {
        later = vec.x1 + DrawingToolDistance.horizontalDistance;
      }
    }
    if (exceedStart && !exceedEnd) {
      later = vec.x1;

      if (vec.x0 > vec.x1) {
        earlier = vec.x0 + DrawingToolDistance.horizontalDistance;
      } else {
        earlier = vec.x0 - DrawingToolDistance.horizontalDistance;
      }
    }

    if (exceedStart && exceedEnd) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endYCoord,
          x1: startXCoord,
          y1: startYCoord,
        );
      }

      earlier = vec.x0 - DrawingToolDistance.horizontalDistance;
      later = vec.x1 + DrawingToolDistance.horizontalDistance;
    }

    if (!exceedEnd && !exceedStart) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endYCoord,
          x1: startXCoord,
          y1: startYCoord,
        );
      }
      earlier = vec.x0;
      later = vec.x1;
    }

    final double startY = _getYIntersection(vec, earlier) ?? 0,
        endingY = _getYIntersection(vec, later) ?? 0,
        startX = earlier,
        endingX = later;

    return Vector(
      x0: startX,
      y0: startY,
      x1: endingX,
      y1: endingY,
    );
  }

  /// Calculates y intersection based on vector points.
  double? _getYIntersection(Vector vector, double x) {
    final double x1 = vector.x0, x2 = vector.x1, x3 = x, x4 = x;
    final double y1 = vector.y0, y2 = vector.y1, y3 = 0, y4 = 10000;
    final double denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    final double numerator = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);

    double mua = numerator / denominator;
    if (denominator == 0) {
      if (numerator == 0) {
        mua = 1;
      } else {
        return null;
      }
    }

    final double y = y1 + mua * (y2 - y1);
    return y;
  }
}
