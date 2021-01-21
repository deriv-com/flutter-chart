/// OHLC interface
abstract class OHLC {
  /// Epoch (the timestamp of the data entry)
  int get epoch;

  /// Open value (first value in OHLC period)
  double get open;

  /// High value (highest value in OHLC period)
  double get high;

  /// Low value (lowest value in OHLC period)
  double get low;

  /// Close value (last value in OHLC period)
  double get close;
}
