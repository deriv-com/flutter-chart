import 'package:meta/meta.dart';

import 'conversion.dart';

List<double> calcGridLineQuotes({
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

List<int> calcGridLineEpochs({
  @required int timeGridInterval,
  @required int rightBoundEpoch,
  @required double canvasWidth,
  @required double msPerPx,
}) {
  final firstRight =
      (rightBoundEpoch - rightBoundEpoch % timeGridInterval).toInt();
  final leftBoundEpoch = rightBoundEpoch -
      pxToMs(
        canvasWidth,
        msPerPx: msPerPx,
      );
  final epochs = <int>[];
  for (int epoch = firstRight;
      epoch >= leftBoundEpoch;
      epoch -= timeGridInterval) {
    epochs.add(epoch);
  }
  return epochs;
}
