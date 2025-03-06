/// Maps a value from one range to another and inverts the result.
///
/// This utility function takes a value from an original range (defined by `oldMin`
/// and `oldMax`) and maps it to a new range (defined by `newMin` and `newMax`),
/// then inverts the result within the new range.
///
/// The function performs the following steps:
/// 1. Clamps the input value to ensure it's within the original range
/// 2. Maps the clamped value from the original range to the new range using linear interpolation
/// 3. Inverts the mapped value within the new range
///
/// This is particularly useful in chart visualization for:
/// - Scaling values between different coordinate systems
/// - Converting between data values and pixel positions
/// - Normalizing values for consistent visual representation
/// - Creating inverse relationships (e.g., when a smaller input should produce a larger output)
///
/// @param value The input value to be converted.
/// @param oldMin The minimum value of the original range.
/// @param oldMax The maximum value of the original range.
/// @param newMin The minimum value of the target range.
/// @param newMax The maximum value of the target range.
/// @return The converted and inverted value in the new range.
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

  // Invert the value within the new range
  // This creates an inverse relationship where:
  // - When input is oldMin, output is newMax
  // - When input is oldMax, output is newMin
  return newMax - newValue + newMin;
}
