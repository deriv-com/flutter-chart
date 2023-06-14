import 'dart:math';
import 'dart:ui';

/// A class that holds point data
/// This class is equivalent to Offest but with customized methods
class Point {
  /// Initializes
  const Point({
    required this.x,
    required this.y,
  });

  /// Related x for the point
  final double x;

  /// Related y for the point
  final double y;

  /// Checks whether the point has been "clicked" by a user at a certain
  /// position on the screen, within a given "affected area" radius.
  ///
  /// The [position] parameter is the location on the screen where the user
  /// clicked, specified as an [Offset] object.
  ///
  /// The [affectedArea] parameter is the radius of the affected area around
  /// the point.
  ///
  /// Returns `true` if the distance between the [position] and the point is
  /// less than the [affectedArea], indicating that the point has been "clicked"
  bool isClicked(Offset position, double affectedArea) =>
      pow(x - position.dx, 2) + pow(y - position.dy, 2) < pow(affectedArea, 2);
}
