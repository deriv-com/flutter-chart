import 'package:meta/meta.dart';

/// The required painting properties of a bar.
class BarPainting {
  /// Initializes the required painting properties of a bar.
  BarPainting({
    @required this.xCenter,
    @required this.yQuote,
    @required this.width,
  });

  /// The center X position of the bar.
  final double xCenter;

  /// Y position of the bar's quote.
  final double yQuote;

  /// The width of the bar.
  final double width;
}
