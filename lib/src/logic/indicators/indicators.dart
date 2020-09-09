import 'package:deriv_chart/src/models/tick.dart';

/// A class to calculate Moving Average, RSI, MACD indicators
class MovingAverage {
  final int length;
  int circIndex = -1;
  bool filled = false;
  double current = double.nan;
  double oneOverLength;
  List<Tick> circularBuffer;
  double total = 0;

  MovingAverage(this.length) {
    this.oneOverLength = 1.0 / length;
    this.circularBuffer = new List<Tick>(length);
  }

  MovingAverage update(Tick entry) {
    Tick lostValue = circularBuffer[circIndex];
    circularBuffer[circIndex] = entry;

    // Maintain totals for Push function
    total += entry.quote;
    total -= lostValue.quote;

    // If not yet filled, just return. Current value should be double.NaN
    if (!filled) {
      current = double.nan;
      return this;
    }

    // Compute the average
    double average = 0.0;
    for (Tick aCircularBuffer in circularBuffer) {
      average += aCircularBuffer.quote;
    }

    current = average * oneOverLength;

    return this;
  }

  MovingAverage push(Tick entry) {
    // Apply the circular buffer
    if (++circIndex == length) {
      circIndex = 0;
    }

    double lostValue = circularBuffer[circIndex]?.quote ?? 0;
    circularBuffer[circIndex] = entry;

    // Compute the average
    total += entry.quote;
    total -= lostValue;

    // If not yet filled, just return. Current value should be double.NaN
    if (!filled && circIndex != length - 1) {
      current = double.nan;
      return this;
    } else {
      // Set a flag to indicate this is the first time the buffer has been filled
      filled = true;
    }

    current = total * oneOverLength;

    return this;
  }

  double getCurrent() {
    return current;
  }

  static List<Tick> movingAverage(List<Tick> input, int period) {
    final MovingAverage ma = new MovingAverage(period);

    final List<Tick> output = List<Tick>(/*input.length*/);

    for (int i = 0; i < input.length; i++) {
      ma.push(input[i]);
      if (!ma.getCurrent().isNaN) {
        output.add(Tick(epoch: input[i].epoch, quote: ma.getCurrent()));
      }
    }

    return output;
  }
}
