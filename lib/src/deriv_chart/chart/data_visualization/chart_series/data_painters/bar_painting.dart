import 'dart:ui';

/// The required painting properties of a bar.
class BarPainting {
  /// Initializes the required painting properties of a bar.
  BarPainting({
    required this.xCenter,
    required this.yQuote,
    required this.width,
    required this.painter,
  });

  /// The center X position of the bar.
  final double xCenter;

  /// Y position of the bar's quote.
  final double yQuote;

  /// The painter to paint the bar with.
  final Paint painter;

  /// The width of the bar.
  final double width;
}