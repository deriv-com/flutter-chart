import 'package:deriv_chart/src/models/tick.dart';

/// A class to calculate Moving Average
// TODO(ramin): It's performance might not be ideal. Its only for the purpose of showing how to add multiple data series to the chart.
class MovingAverage {
  /// Initializes
  MovingAverage(this._period) {
    _oneOverLength = 1.0 / _period;
    _circularBuffer = List<Tick>(_period);
  }

  final int _period;
  int _index = -1;
  bool _filled = false;
  double _current = double.nan;
  double _oneOverLength;
  List<Tick> _circularBuffer;
  double _total = 0;

  /// Push new entry to calculate average for the next window
  MovingAverage push(Tick entry) {
    // Apply the circular buffer
    if (++_index == _period) {
      _index = 0;
    }

    final double lostValue = _circularBuffer[_index]?.quote ?? 0;
    _circularBuffer[_index] = entry;

    // Compute the average
    _total += entry.quote;
    _total -= lostValue;

    // If not yet filled, just return. Current value should be double.NaN
    if (!_filled && _index != _period - 1) {
      _current = double.nan;
      return this;
    } else {
      // Set a flag to indicate this is the first time the buffer has been filled
      _filled = true;
    }

    _current = _total * _oneOverLength;

    return this;
  }

  /// Calculates Moving Average for [input] and return its data.
  static List<Tick> movingAverage(List<Tick> input, int period) {
    final MovingAverage ma = MovingAverage(period);

    final List<Tick> output = <Tick>[];

    for (int i = 0; i < input.length; i++) {
      ma.push(input[i]);
      if (!ma._current.isNaN) {
        output.add(Tick(epoch: input[i].epoch, quote: ma._current));
      }
    }

    return output;
  }
}
