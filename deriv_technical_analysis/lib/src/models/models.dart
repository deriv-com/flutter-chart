/// An element of Indicator result
abstract class Result {
  /// Epoch
  int get epoch;

  /// Quote
  double get quote;
}

/// OHLC interface
abstract class OHLC implements Result {
  /// Open value (first value in OHLC period)
  double get open;

  /// High value (highest value in OHLC period)
  double get high;

  /// Low value (lowest value in OHLC period)
  double get low;

  /// Close value (last value in OHLC period)
  double get close;
}

/// A result model class
class ResultEntry implements Result {
  /// Initializes
  ResultEntry(this.epoch, this.quote);

  /// Epoch
  @override
  final int epoch;

  /// Quote
  @override
  final double quote;
}

/// A Tick input element.
class TickEntry implements OHLC {
  /// Initializer
  const TickEntry({this.epoch, this.quote});

  /// Epoch
  @override
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
class OHLCEntry extends TickEntry {
  /// Initializes
  const OHLCEntry(int epoch, this.open, this.close, this.high, this.low)
      : super(epoch: epoch, quote: close);

  @override
  final double close;

  @override
  final double high;

  @override
  final double low;

  @override
  final double open;
}
