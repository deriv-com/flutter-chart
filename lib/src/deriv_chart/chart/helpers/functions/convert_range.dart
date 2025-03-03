/// Converts range
double convertRange(
    double value, double oldMin, double oldMax, double newMin, double newMax) {
  // Ensure the value is within the old range
  final double clampedValue = value.clamp(oldMin, oldMax);

  // Map the old range to the new range
  final double oldRange = oldMax - oldMin;
  final double newRange = newMax - newMin;

  // Calculate the scaled value in the new range
  final double newValue =
      (((clampedValue - oldMin) * newRange) / oldRange) + newMin;

  /// Inverse the value
  return newMax - newValue + newMin;
}
