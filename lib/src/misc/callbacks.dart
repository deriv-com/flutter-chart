/// Called when chart is scrolled or zoomed.
///
/// [leftEpoch] is an epoch value of the chart's left edge.
/// [rightEpoch] is an epoch value of the chart's right edge.
typedef VisibleAreaChangedCallback = Function(int leftEpoch, int rightEpoch);

/// Called when the quotes in y-axis is changed
///
/// [topQuote] is an quote value of the chart's top edge.
/// [bottomQuote] is an quote value of the chart's bottom edge.
typedef VisibleQuoteAreaChangedCallback = Function(
    double topQuote, double bottomQuote);
