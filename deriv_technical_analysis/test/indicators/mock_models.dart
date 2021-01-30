import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

/// Indicator's input mock implementation.
class MockInput implements DataInput {
  /// Initializes
  MockInput(this.entries);

  @override
  final List<OHLC> entries;

  @override
  Result createResult(int index, double value) => MockResult(value);
}

/// A result model class
class MockResult implements Result {
  /// Initializes
  MockResult(this.quote);

  /// Quote
  @override
  final double quote;
}

/// A Tick input element.
class MockTick implements OHLC {
  /// Initializer
  const MockTick({this.epoch, this.quote});

  /// Epoch
  final int epoch;

  /// Quote
  @override
  final double quote;

  @override
  double get close => quote;

  @override
  double get high => quote;

  @override
  double get low => quote;

  @override
  double get open => quote;
}

/// An OHLC model class
class MockOHLC extends MockTick {
  /// Initializes
  const MockOHLC(int epoch, this.open, this.close, this.high, this.low)
      : super(epoch: epoch, quote: close);

  /// Initializes with name parameters.
  const MockOHLC.withNames({
    int epoch,
    double open,
    double close,
    double high,
    double low,
  }) : this(epoch, open, close, high, low);

  @override
  final double close;

  @override
  final double high;

  @override
  final double low;

  @override
  final double open;
}
