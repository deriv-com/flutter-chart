import '../models/candle.dart';

/// Returns a reference to candle with exact or closest epoch to [targetEpoch].
///
/// Returns [null] if list is empty.
/// Expects a list of candles to be sorted.
Candle findClosestToEpoch(int targetEpoch, List<Candle> candles) {
  if (candles.isEmpty) return null;

  var left = 0;
  var right = candles.length - 1;

  while (right - left > 1) {
    final mid = ((left + right) / 2).floor();
    final candle = candles[mid];

    if (candle.epoch < targetEpoch) {
      left = mid;
    } else if (candle.epoch > targetEpoch) {
      right = mid;
    } else {
      return candle;
    }
  }

  final distanceToLeft = (targetEpoch - candles[left].epoch).abs();
  final distanceToRight = (targetEpoch - candles[right].epoch).abs();

  if (distanceToLeft <= distanceToRight) {
    return candles[left];
  } else {
    return candles[right];
  }
}
