import 'package:deriv_chart/src/models/tick.dart';

import 'indicator.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator<T extends Tick> implements Indicator {
  /// Initializes
  AbstractIndicator(this.entries);

  /// List of data to calculate indicator values on.
  final List<T> entries;

  /// Gets the epoch of the given [index]
  int getEpochOfIndex(int index) => entries[index].epoch;
}
