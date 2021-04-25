import 'package:meta/meta.dart';

/// The required painting properties of a candle.
class CandlePainting {
  /// Initialzes the required painting properties of a candle.
  const CandlePainting({
    required this.xCenter,
    required this.yHigh,
    required this.yLow,
    required this.yOpen,
    required this.yClose,
    required this.width,
  });

  /// The center X position of the candle.
  final double xCenter;

  /// Y position of the candle's high value.
  final double yHigh;

  /// Y position of the candle's low value.
  final double yLow;

  /// Y position of the candle's open value.
  final double yOpen;

  /// Y position of the candle's close value.
  final double yClose;

  /// The width of the candle.
  final double width;
}
