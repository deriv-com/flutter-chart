import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:flutter/material.dart';

// Keep in mind these 2 use cases:
// 1) live chart
// 2) closed contract
class XAxisModel extends ChangeNotifier {
  XAxisModel({
    @required int nowEpoch,
    @required int granularity,
  }) {
    _nowEpoch = nowEpoch;
    rightBoundEpoch = nowEpoch + convertPxToMs(XAxisModel.maxCurrentTickOffset);
    updateGranularity(granularity);
  }

  /// Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;

  /// Scaling will not resize intervals to be smaller than this.
  static const int minIntervalWidth = 4;

  /// Scaling will not resize intervals to be bigger than this.
  static const int maxIntervalWidth = 80;

  /// Default to this interval width on granularity change.
  static const int defaultIntervalWidth = 20;

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  /// Horizontal panning is controlled by this variable.
  int rightBoundEpoch;

  int _nowEpoch;

  double width;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  /// Scaling is controlled by this variable.
  double msPerPx = 1000;

  /// Previous value of [msPerPx]. Used for scaling computation.
  double _prevMsPerPx;

  int _granularity;

  bool _autoPanEnabled = true;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

  /// Epoch value of the leftmost chart's edge.
  int get leftBoundEpoch => rightBoundEpoch - convertPxToMs(width);

  /// Current scrolling upper bound.
  int get maxRightBoundEpoch =>
      _nowEpoch + convertPxToMs(XAxisModel.maxCurrentTickOffset);

  bool get isAutoPanning => _autoPanEnabled && rightBoundEpoch > _nowEpoch;

  /// Bounds and default for [msPerPx].
  double get _minScale => granularity / XAxisModel.maxIntervalWidth;
  double get _maxScale => granularity / XAxisModel.minIntervalWidth;
  double get _defaultScale => granularity / XAxisModel.defaultIntervalWidth;

  void updateNowEpoch(int newNowEpoch) {
    final elapsedMs = newNowEpoch - _nowEpoch;
    _nowEpoch = newNowEpoch;
    if (isAutoPanning) {
      rightBoundEpoch += elapsedMs;
    }
    notifyListeners();
  }

  void updateGranularity(int newGranularity) {
    if (_granularity == newGranularity) return;
    _granularity = newGranularity;
    msPerPx = _defaultScale;
    rightBoundEpoch = maxRightBoundEpoch;
  }

  void enableAutoPan() {
    _autoPanEnabled = true;
    notifyListeners();
  }

  void disableAutoPan() {
    _autoPanEnabled = false;
    notifyListeners();
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
    if (isAutoPanning) {
      _scaleWithNowFixed(details);
    } else {
      _scaleWithFocalPointFixed(details);
    }
    notifyListeners();
  }

  void _scaleWithNowFixed(ScaleUpdateDetails details) {
    final nowToRightBound = convertMsToPx(rightBoundEpoch - _nowEpoch);
    _scale(details.scale);
    rightBoundEpoch = _nowEpoch + convertPxToMs(nowToRightBound);
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = width - details.focalPoint.dx;
    final focalEpoch = rightBoundEpoch - convertPxToMs(focalToRightBound);
    _scale(details.scale);
    rightBoundEpoch = focalEpoch + convertPxToMs(focalToRightBound);
  }

  void _scale(double scale) {
    msPerPx = (_prevMsPerPx / scale).clamp(_minScale, _maxScale);
  }

  void onPanUpdate(DragUpdateDetails details) {
    rightBoundEpoch -= convertPxToMs(details.delta.dx);
    notifyListeners();
  }
}
