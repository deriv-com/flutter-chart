import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:flutter/material.dart';

// Keep in mind these 2 use cases:
// 1) live chart
// 2) closed contract
class XAxisModel extends ChangeNotifier {
  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;

  /// Scaling will not resize intervals to be smaller than this.
  static const int minIntervalWidth = 4;

  /// Scaling will not resize intervals to be bigger than this.
  static const int maxIntervalWidth = 80;

  /// Default to this interval width on granularity change.
  static const int defaultIntervalWidth = 20;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  /// Scaling is controlled by this variable.
  double msPerPx = 1000;

  /// Previous value of [msPerPx]. Used for scaling computation.
  double _prevMsPerPx;

  int _granularity;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

  /// Bounds and default for [msPerPx].
  double get _minScale => granularity / XAxisModel.maxIntervalWidth;
  double get _maxScale => granularity / XAxisModel.minIntervalWidth;
  double get _defaultScale => granularity / XAxisModel.defaultIntervalWidth;

  void updateGranularity(int newGranularity) {
    _granularity = newGranularity;
    msPerPx = _defaultScale;
  }

  /// Convert px to ms using current scale.
  int convertPxToMs(double px) {
    return pxToMs(px, msPerPx: msPerPx);
  }

  /// Convert ms to px using current scale.
  double convertMsToPx(int ms) {
    return msToPx(ms, msPerPx: msPerPx);
  }

  void onScaleStart(ScaleStartDetails details) {
    _prevMsPerPx = msPerPx;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    msPerPx = (_prevMsPerPx / details.scale).clamp(_minScale, _maxScale);
    notifyListeners();
  }
}
