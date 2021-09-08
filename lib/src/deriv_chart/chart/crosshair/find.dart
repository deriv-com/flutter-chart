import 'package:deriv_chart/src/models/tick.dart';

/// Returns a reference to candle with exact or closest epoch to [targetEpoch].
///
/// Returns [null] if list is empty.
/// Expects a list of candles to be sorted.
Tick? findClosestToEpoch(int targetEpoch, List<Tick> ticks) {
  if (ticks.isEmpty) {
    return null;
  }

  final double index = findEpochIndex(targetEpoch, ticks);

  if (index < 0) {
    return ticks.first;
  } else if (index > ticks.length - 1) {
    return ticks.last;
  } else {
    final Tick leftTick = ticks[index.floor()];
    final Tick rightTick = ticks[index.ceil()];
    final int distanceToLeft = targetEpoch - leftTick.epoch;
    final int distanceToRight = rightTick.epoch - targetEpoch;
    return distanceToLeft <= distanceToRight ? leftTick : rightTick;
  }
}

/// Returns a reference to [Tick] with exact or closest index to [index].
///
/// Expects a list of [Tick]s to be sorted.
int findClosestTickToIndex(double index, List<Tick> ticks) {
  if (ticks.isEmpty) {
    return index.floor();
  }

  if (index < 0) {
    return 0;
  } else if (index > ticks.length - 1) {
    return ticks.length - 1;
  } else {
    final int leftIndex = index.floor();
    final int rightIndex = index.ceil();
    final double distanceToLeft = index - leftIndex;
    final double distanceToRight = rightIndex - index;
    return distanceToLeft <= distanceToRight ? leftIndex : rightIndex;
  }
}

/// Finds closest index in the [ticks] to the [target].
int findClosestIndex(double target, List<Tick> ticks) {
  int low = 0;
  int high = ticks.length - 1;

  while (low <= high) {
    final int mid = (high + low) ~/ 2;

    if (target < mid) {
      high = mid - 1;
    } else if (target > mid) {
      low = mid + 1;
    } else {
      return mid;
    }
  }

  return (low - target) < (target - high) ? low : high;
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
