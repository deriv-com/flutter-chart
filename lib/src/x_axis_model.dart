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

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  /// Horizontal panning is controlled by this variable.
  int rightBoundEpoch;

  int nowEpoch;

  double canvasWidth;

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
  int get leftBoundEpoch => rightBoundEpoch - convertPxToMs(canvasWidth);

  bool get isAutoPanning => _autoPanEnabled && rightBoundEpoch > nowEpoch;

  /// Bounds and default for [msPerPx].
  double get _minScale => granularity / XAxisModel.maxIntervalWidth;
  double get _maxScale => granularity / XAxisModel.minIntervalWidth;
  double get _defaultScale => granularity / XAxisModel.defaultIntervalWidth;

  void updateGranularity(int newGranularity) {
    _granularity = newGranularity;
    msPerPx = _defaultScale;
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
    final nowToRightBound = convertMsToPx(rightBoundEpoch - nowEpoch);
    _updateScale(details.scale);
    rightBoundEpoch = nowEpoch + convertPxToMs(nowToRightBound);
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = canvasWidth - details.focalPoint.dx;
    final focalEpoch = rightBoundEpoch - convertPxToMs(focalToRightBound);
    _updateScale(details.scale);
    rightBoundEpoch = focalEpoch + convertPxToMs(focalToRightBound);
  }

  void _updateScale(double scale) {
    msPerPx = (_prevMsPerPx / scale).clamp(_minScale, _maxScale);
  }

  void onPanUpdate(DragUpdateDetails details) {
    rightBoundEpoch -= convertPxToMs(details.delta.dx);
    notifyListeners();
  }
}
