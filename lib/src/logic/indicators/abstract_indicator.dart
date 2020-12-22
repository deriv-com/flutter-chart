import 'package:deriv_chart/src/models/tick.dart';

/// Bass class of all indicators.
abstract class AbstractIndicator<T extends Tick> {
  /// Initializes
  AbstractIndicator(this.entries);

  /// List of data to calculate indicator values on.
  final List<T> entries;

  /// Gets the epoch of the given [index]
  // TODO(Ramin): Handle indicator offset here.
  int getEpochOfIndex(int index) => entries[index].epoch;

  /// Value of the indicator for the given [index].
  Tick getValue(int index);
}
