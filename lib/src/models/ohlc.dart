/// OHLC interface
abstract class OHLC {
  /// Epoch
  int get epoch;

  /// Open value
  double get open;

  /// High value
  double get high;

  /// Low value
  double get low;

  /// Close value
  double get close;
}
