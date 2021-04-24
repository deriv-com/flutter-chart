/// Called when chart is scrolled or zoomed.
///
/// [leftEpoch] is an epoch value of the chart's left edge.
/// [rightEpoch] is an epoch value of the chart's right edge.

// @dart=2.9

typedef VisibleAreaChangedCallback = Function(int leftEpoch, int rightEpoch);
