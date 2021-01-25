import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Base class of all indicators.
///
/// Holds common functionalities of indicators like getting epoch for an index or handling indicator's offset.
abstract class Indicator {
  /// Initializes
  Indicator(this.entries, {this.offset = 10})
      : _entriesInterval = entries.length > 2
            ? entries.last.epoch - entries[entries.length - 2].epoch
            : 1000;

  /// List of data to calculate indicator values on.
  final List<OHLC> entries;

  /// The offset of the indicator.
  final int offset;

  /// Offset steps.
  final int _entriesInterval;

  /// Gets the epoch of the given [index]
  // TODO(Ramin): Handle indicator offset here.
  int getEpochOfIndex(int index) =>
      entries[index].epoch + (offset * _entriesInterval);

  /// Value of the indicator for the given [index].
  Tick getValue(int index);
}
