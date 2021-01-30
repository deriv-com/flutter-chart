/// An element of Indicator result
abstract class Result {
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