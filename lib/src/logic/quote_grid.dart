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
