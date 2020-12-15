import 'package:deriv_chart/src/models/tick.dart';

import 'indicator.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator<T extends Tick> implements Indicator {
  /// Initializes
  AbstractIndicator(this.entries);

  /// List of data to calculate indicator values on.
  final List<T> entries;

  /// Gets the epoch of the given [index]
  // TODO(Ramin): Handle indicator offset here.
  int getEpochOfIndex(int index) => entries[index].epoch;

  /// Push a new value to indicator.
  T push(T t) {
    entries.add(t);
    return getValue(entries.length - 1);
  }

  T replaceLast(T t) {
    entries.removeLast();
    return push(t);
  }
}
