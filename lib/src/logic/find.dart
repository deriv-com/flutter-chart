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

/// Returns index of the [epoch] location in [ticks].
///
/// E.g. `3` if [epoch] matches epoch of `ticks[3]`.
/// `3.5` if [epoch] is between epochs of `ticks[3]` and `ticks[4]`.
/// `-0.5` if [epoch] is before the first tick.
/// `9.5` if [epoch] is after the last tick and the last tick index is `9`.
double findEpochIndex(int epoch, List<Tick> ticks) {
  if (ticks.isEmpty) {
    throw ArgumentError('No ticks given.');
  }

  int left = -1;
  int right = ticks.length;

  while (right - left > 1) {
    final int mid = (left + right) ~/ 2;
    final int pivot = ticks[mid].epoch;
    if (epoch < pivot) {
      right = mid;
    } else if (epoch > pivot) {
      left = mid;
    } else {
      return mid.toDouble();
    }
  }

  if (left >= 0 && epoch == ticks[left].epoch) {
    return left.toDouble();
  } else if (right < ticks.length && epoch == ticks[right].epoch) {
    return right.toDouble();
  } else {
    return (left + right) / 2;
  }
}
