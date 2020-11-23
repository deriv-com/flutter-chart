import 'package:meta/meta.dart';

List<double> gridQuotes({
  @required double quoteGridInterval,
  @required double topBoundQuote,
  @required double bottomBoundQuote,
  @required double canvasHeight,
  @required double topPadding,
  @required double bottomPadding,
}) {
  final pixelToQuote = (topBoundQuote - bottomBoundQuote) /
      (canvasHeight - topPadding - bottomPadding);
  final topEdgeQuote = topBoundQuote + topPadding * pixelToQuote;
  final bottomEdgeQuote = bottomBoundQuote - bottomPadding * pixelToQuote;
  final gridLineQuotes = <double>[];
  for (var q = topEdgeQuote - topEdgeQuote % quoteGridInterval;
      q > bottomEdgeQuote;
      q -= quoteGridInterval) {
    if (q < topEdgeQuote) gridLineQuotes.add(q);
  }
  return gridLineQuotes;
}

double quotePerPx({
  @required double topBoundQuote,
  @required double bottomBoundQuote,
  @required double yTopBound,
  @required double yBottomBound,
}) {
  final quoteDiff = topBoundQuote - bottomBoundQuote;
  final pxDiff = yBottomBound - yTopBound;

  return quoteDiff / pxDiff;
}

double quoteGridInterval(
  double quotePerPx, {
  double minDistanceBetweenLines = 60,
  // Options for quote labels value distance in Y-Axis. One of these intervals will be selected to be the distance between Y-Axis labels
  List<double> intervals = const [
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
    final distanceBetweenLines = quoteInterval / quotePerPx;
    return distanceBetweenLines >= minDistanceBetweenLines;
  }

  return intervals.firstWhere(
    hasEnoughDistanceBetweenLines,
    orElse: () => intervals.last,
  );
}
