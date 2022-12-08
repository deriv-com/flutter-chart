/// The required painting properties of a ohlc.
class OhlcPainting {
  /// Initialzes the required painting properties of a ohlc.
  const OhlcPainting({
    required this.xCenter,
    required this.yHigh,
    required this.yLow,
    required this.yOpen,
    required this.yClose,
    required this.width,
  });

  /// The center X position of the ohlc.
  final double xCenter;

  /// Y position of the ohlc's high value.
  final double yHigh;

  /// Y position of the ohlc's low value.
  final double yLow;

  /// Y position of the ohlc's open value.
  final double yOpen;

  /// Y position of the ohlc's close value.
  final double yClose;

  /// The width of the ohlc candle.
  final double width;
}
