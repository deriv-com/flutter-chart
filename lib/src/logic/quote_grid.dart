import 'package:meta/meta.dart';

///A Model for calculating the grid intervals and quotes.
class YAxisModel {
  ///Initializes a Model for calculating the grid intervals and quotes.
  YAxisModel({
    required double topBoundQuote,
    required double bottomBoundQuote,
    required double yTopBound,
    required double yBottomBound,
    required double canvasHeight,
    required double topPadding,
    required double bottomPadding,
  })   : _quoteGridInterval = quoteGridInterval(
          quotePerPx(
              yTopBound: yTopBound,
              yBottomBound: yBottomBound,
              bottomBoundQuote: bottomBoundQuote,
              topBoundQuote: topBoundQuote),
        ),
        _topBoundQuote = topBoundQuote,
        _bottomBoundQuote = bottomBoundQuote,
        _canvasHeight = canvasHeight,
        _topPadding = topPadding,
        _bottomPadding = bottomPadding;

  final double _quoteGridInterval;
  final double _topBoundQuote;
  final double _bottomBoundQuote;
  final double _canvasHeight;
  final double _topPadding;
  final double _bottomPadding;

  /// Calculates the grid lines for a quote.
  List<double> gridQuotes() {
    final double pixelToQuote = (_topBoundQuote - _bottomBoundQuote) /
        (_canvasHeight - _topPadding - _bottomPadding);
    final double topEdgeQuote = _topBoundQuote + _topPadding * pixelToQuote;
    final double bottomEdgeQuote =
        _bottomBoundQuote - _bottomPadding * pixelToQuote;
    final List<double> gridLineQuotes = <double>[];
    for (double q = topEdgeQuote - topEdgeQuote % _quoteGridInterval;
        q > bottomEdgeQuote;
        q -= _quoteGridInterval) {
      if (q < topEdgeQuote) {
        gridLineQuotes.add(q);
      }
    }
    return gridLineQuotes;
  }
}

/// Calculates the quotes that can be placed per pixel.
double quotePerPx({
  required double topBoundQuote,
  required double bottomBoundQuote,
  required double yTopBound,
  required double yBottomBound,
}) {
  final double quoteDiff = topBoundQuote - bottomBoundQuote;
  final double pxDiff = yBottomBound - yTopBound;

  return quoteDiff / pxDiff;
}

/// Calculates the grid interval of a quote by getting the [quotePerPx] value.
double quoteGridInterval(
  double quotePerPx, {
  double minDistanceBetweenLines = 60,
  // Options for quote labels value distance in Y-Axis. One of these intervals will be selected to be the distance between Y-Axis labels
  List<double> intervals = const <double>[
    0.0000000025,
    0.000000001,
    0.000000005,
    0.000000025,
    0.00000005,
    0.0000001,
    0.0000005,
    0.0000025,
    0.000005,
    0.00001,
    0.00005,
    0.00025,
    0.0005,
    0.001,
    0.005,
    0.025,
    0.05,
    0.1,
    0.25,
    0.5,
    1,
    2,
    2.5,
    5,
    10,
    25,
    50,
    100,
    250,
    500,
    1000,
    5000,
    10000,
    100000,
  ],
}) {
  bool hasEnoughDistanceBetweenLines(double quoteInterval) {
    final double distanceBetweenLines = quoteInterval / quotePerPx;
    return distanceBetweenLines >= minDistanceBetweenLines;
  }

  return intervals.firstWhere(
    hasEnoughDistanceBetweenLines,
    orElse: () => intervals.last,
  );
}
