import '../models/candle.dart';

/// Returns a reference to candle with exact or closest epoch to [targetEpoch].
///
/// Returns [null] if list is empty.
/// Expects a list of candles to be sorted.
Candle findClosestToEpoch(int targetEpoch, List<Candle> candles) {
  if (candles.isEmpty) return null;

  int left = 0; // inclusive
  int right = candles.length; // exclusive

  while (left < right) {
    final mid = ((left + right) / 2).floor();

    final candle = candles[mid];

    if (candle.epoch < targetEpoch) {
      left = mid + 1;
    } else if (candle.epoch > targetEpoch) {
      right = mid;
    } else {
      return candle;
    }
  }

  return candles[left];
}
