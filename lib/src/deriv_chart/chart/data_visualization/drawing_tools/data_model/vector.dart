/// A class that holds vector data
class Vector {
  /// Initializes
  const Vector({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
  });

  /// Vector with zero coordinate.
  const Vector.zero() : this(x0: 0, y0: 0, x1: 0, y1: 0);

  /// Related x for starting point of the vector
  final double x0;

  /// Related y for starting point of the vector
  final double y0;

  /// Related x for ending point of the vector
  final double x1;

  /// Related y for ending point of the vector
  final double y1;
}
