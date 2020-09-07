import 'package:deriv_chart/src/models/tick.dart';

/// Returns a reference to candle with exact or closest epoch to [targetEpoch].
///
/// Returns [null] if list is empty.
/// Expects a list of candles to be sorted.
Tick findClosestToEpoch(int targetEpoch, List<Tick> ticks) {
  if (ticks.isEmpty) return null;

  int left = 0;
  int right = ticks.length - 1;

  while (right - left > 1) {
    final mid = ((left + right) / 2).floor();
    final tick = ticks[mid];

    if (tick.epoch < targetEpoch) {
      left = mid;
    } else if (tick.epoch > targetEpoch) {
      right = mid;
    } else {
      return tick;
    }
  }

  final distanceToLeft = (targetEpoch - ticks[left].epoch).abs();
  final distanceToRight = (targetEpoch - ticks[right].epoch).abs();

  if (distanceToLeft <= distanceToRight)
    return ticks[left];
  else
    return ticks[right];
}
