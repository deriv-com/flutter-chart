import 'package:meta/meta.dart';

/// The required painting properties of a candle.
class CandlePainting {
  /// Initialzes the required painting properties of a candle.
  CandlePainting({
    @required this.xCenter,
    @required this.yHigh,
    @required this.yLow,
    @required this.yOpen,
    @required this.yClose,
    @required this.width,
  });

  /// The center X axis of the candle.
  final double xCenter;

  /// The high y axis of the candle.
  final double yHigh;

  /// The low y axis of the candle.
  final double yLow;

  /// The open y axis of the candle.
  final double yOpen;

  /// The close y axis of the candle.
  final double yClose;

  /// The width of the candle.
  final double width;
}
