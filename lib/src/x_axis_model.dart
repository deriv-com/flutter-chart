import 'package:flutter/material.dart';

// Keep in mind these 2 use cases:
// 1) live chart
// 2) closed contract
class XAxisModel extends ChangeNotifier {
  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;

  static const int maxIntervalWidth = 80;

  static const int defaultIntervalWidth = 20;

  static const int minIntervalWidth = 4;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  /// Scaling is controlled by this variable.
  double msPerPx = 1000;

  /// Previous value of [msPerPx]. Used for scaling computation.
  double prevMsPerPx;

  void onScaleStart(ScaleStartDetails details) {
    prevMsPerPx = msPerPx;
  }

  void onScaleUpdate(ScaleUpdateDetails details, int granularity) {
    msPerPx = (prevMsPerPx / details.scale).clamp(
      _getMinScale(granularity),
      _getMaxScale(granularity),
    );
  }

  double _getMinScale(int granularity) {
    return granularity / XAxisModel.maxIntervalWidth;
  }

  double _getMaxScale(int granularity) {
    return granularity / XAxisModel.minIntervalWidth;
  }
}
