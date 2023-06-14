/// A class that holds epoch and yCoord of the edge points.
class EdgePoint {
  /// Initializes
  const EdgePoint({
    this.epoch = 0,
    this.yCoord = 0,
  });

  /// Epoch.
  final int epoch;

  /// Y coordinates.
  final double yCoord;
}
