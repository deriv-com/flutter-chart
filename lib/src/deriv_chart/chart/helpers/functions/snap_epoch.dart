/// Returns the epoch aligned to the start of its granularity interval.
///
/// - If [granularity] is 1000 or less (i.e. tick data), the original [epoch] is returned unchanged.
/// - If [granularity] is greater than 1000 (i.e. candles),
/// the [epoch] is snapped to the start of its granularity bucket by
/// rounding down to the nearest multiple of [granularity].
int snapEpochToGranularity(
  int epoch,
  int granularity,
) {
  if (granularity <= 1000) {
    return epoch;
  }
  return (epoch ~/ granularity) * granularity;
}
