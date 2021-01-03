import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Base class of all indicators.
///
/// Holds common functionalities of indicators like getting epoch for an index or handling indicator's offset.
abstract class Indicator {
  /// Initializes
  Indicator(this.entries);

  /// List of data to calculate indicator values on.
  final List<OHLC> entries;

  /// Gets the epoch of the given [index]
  // TODO(Ramin): Handle indicator offset here.
  int getEpochOfIndex(int index) => entries[index].epoch;

  /// Value of the indicator for the given [index].
  Tick getValue(int index);
}
