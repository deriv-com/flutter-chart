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
  List<double> intervals = const [
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
