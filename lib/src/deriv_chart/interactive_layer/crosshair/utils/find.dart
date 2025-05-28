import 'package:deriv_chart/src/models/tick.dart';

/// Returns the closest previous tick to the [crosshairTick].
///
/// Returns `null` if list is empty or if there's no tick before the [crosshairTick].
/// Expects a list of ticks to be sorted by epoch in ascending order.
///
/// This method uses binary search to efficiently find the closest previous tick,
/// resulting in O(log n) time complexity, where n is the number of ticks in the list.
/// This makes it suitable for use with large datasets.
Tick? findClosestPreviousTick(Tick crosshairTick, List<Tick> ticks) {
  if (ticks.isEmpty) {
    return null;
  }

  // If crosshairTick is before the first tick, there's no previous tick
  if (crosshairTick.epoch <= ticks.first.epoch) {
    return null;
  }

  // Binary search to find the position where crosshairTick would be inserted
  int left = 0;
  int right = ticks.length - 1;

  while (left <= right) {
    final int mid = (left + right) ~/ 2;

    if (ticks[mid].epoch < crosshairTick.epoch) {
      left = mid + 1;
    } else if (ticks[mid].epoch > crosshairTick.epoch) {
      right = mid - 1;
    } else {
      // Exact match found, return the previous tick
      return mid > 0 ? ticks[mid - 1] : null;
    }
  }

  // At this point, 'right' points to the largest element smaller than crosshairTick.epoch
  // and 'left' points to the smallest element greater than or equal to crosshairTick.epoch
  return right >= 0 ? ticks[right] : null;
}

/// Returns a reference to candle with exact or closest epoch to [targetEpoch].
///
/// Returns `null` if list is empty.
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

/// Finds closest index in the [ticks] to the [index].
int findClosestIndex(double index, List<Tick> ticks) {
  if (ticks.isEmpty) {
    return index.round();
  }

  if (index < 0) {
    return 0;
  } else if (index > ticks.length - 1) {
    return ticks.length - 1;
  } else {
    return index.round();
  }
}

/// Binary search to find closest index to the [epoch].
int findClosestIndexBinarySearch(int epoch, List<Tick>? entries) {
  if (entries == null || entries.isEmpty) {
    return 0;
  }

  int lo = 0;
  int hi = entries.length - 1;
  int localEpoch = epoch;

  if (localEpoch > entries[hi].epoch) {
    localEpoch = entries[hi].epoch;
    return hi;
  }

  while (lo <= hi) {
    final int mid = (hi + lo) ~/ 2;
    // int getEpochOf(T t, int index) => t.epoch;
    if (localEpoch < entries[mid].epoch) {
      hi = mid - 1;
    } else if (localEpoch > entries[mid].epoch) {
      lo = mid + 1;
    } else {
      return mid;
    }
  }

  // Check if hi is less than 0
  if (hi < 0) {
    return lo; // or another appropriate value to indicate the closest index
  }

  return (entries[lo].epoch - localEpoch) < (localEpoch - entries[hi].epoch)
      ? lo
      : hi;
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
