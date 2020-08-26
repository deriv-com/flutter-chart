import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:flutter/material.dart';

// Keep in mind these 2 use cases:
// 1) live chart
// 2) closed contract
class XAxisModel extends ChangeNotifier {
  XAxisModel({
    @required int firstCandleEpoch,
    @required int granularity,
    @required AnimationController animationController,
  }) {
    _nowEpoch = DateTime.now().millisecondsSinceEpoch;
    _firstCandleEpoch = firstCandleEpoch ?? _nowEpoch;
    _granularity = granularity;
    msPerPx = _defaultScale;
    rightBoundEpoch = _maxRightBoundEpoch;

    _rightEpochAnimationController = animationController
      ..addListener(() {
        rightBoundEpoch = _rightEpochAnimationController.value.toInt();
        if (hasHitLimit) {
          _rightEpochAnimationController.stop();
        }
      });
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
  int _rightBoundEpoch;

  int get rightBoundEpoch => _rightBoundEpoch;

  set rightBoundEpoch(int rightBoundEpoch) {
    _rightBoundEpoch = rightBoundEpoch.clamp(
      _minRightBoundEpoch,
      _maxRightBoundEpoch,
    );
  }

  AnimationController _rightEpochAnimationController;

  int _firstCandleEpoch;

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
  int get leftBoundEpoch => rightBoundEpoch - msFromPx(width);

  /// Current scrolling lower bound.
  int get _minRightBoundEpoch =>
      _firstCandleEpoch + msFromPx(XAxisModel.maxCurrentTickOffset);

  /// Current scrolling upper bound.
  int get _maxRightBoundEpoch =>
      _nowEpoch + msFromPx(XAxisModel.maxCurrentTickOffset);

  /// Chart pan is currently being animated (without user input).
  bool get animatingPan =>
      _autoPanning || _rightEpochAnimationController?.isAnimating ?? false;

  /// Current tick is visible, chart is being autopanned.
  bool get _autoPanning => _autoPanEnabled && rightBoundEpoch > _nowEpoch;

  /// Has hit left or right panning limit.
  bool get hasHitLimit =>
      rightBoundEpoch == _maxRightBoundEpoch ||
      rightBoundEpoch == _minRightBoundEpoch;

  /// Bounds and default for [msPerPx].
  double get _minScale => granularity / XAxisModel.maxIntervalWidth;
  double get _maxScale => granularity / XAxisModel.minIntervalWidth;
  double get _defaultScale => granularity / XAxisModel.defaultIntervalWidth;

  /// Updates right panning limit and autopan if enabled.
  void updateNowEpoch(int newNowEpoch) {
    final elapsedMs = newNowEpoch - _nowEpoch;
    _nowEpoch = newNowEpoch;
    if (_autoPanning) {
      rightBoundEpoch += elapsedMs;
    }
    notifyListeners();
  }

  /// Updates left panning limit.
  void updateFirstCandleEpoch(int firstCandleEpoch) {
    _firstCandleEpoch = firstCandleEpoch ?? _nowEpoch;
  }

  /// Resets scale and pan on granularity change.
  void updateGranularity(int newGranularity) {
    if (_granularity == newGranularity) return;
    _granularity = newGranularity;
    msPerPx = _defaultScale;
    rightBoundEpoch = _maxRightBoundEpoch;
  }

  /// Enables autopanning when current tick is visible.
  void enableAutoPan() {
    _autoPanEnabled = true;
    notifyListeners();
  }

  /// Disables autopanning when current tick is visible.
  /// E.g. crosshair disables autopan while it is visible.
  void disableAutoPan() {
    _autoPanEnabled = false;
    notifyListeners();
  }

  /// Convert px to ms using current scale.
  int msFromPx(double px) {
    return pxToMs(px, msPerPx: msPerPx);
  }

  /// Convert ms to px using current scale.
  double pxFromMs(int ms) {
    return msToPx(ms, msPerPx: msPerPx);
  }

  /// Get x position of epoch.
  double xFromEpoch(int epoch) => epochToCanvasX(
        epoch: epoch,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: width,
        msPerPx: msPerPx,
      );

  /// Get epoch of x position.
  int epochFromX(double x) => canvasXToEpoch(
        x: x,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: width,
        msPerPx: msPerPx,
      );

  /// Called at the start of scale and pan gestures.
  void onScaleAndPanStart(ScaleStartDetails details) {
    _rightEpochAnimationController.stop();
    _prevMsPerPx = msPerPx;
  }

  /// Called when user is scaling the chart.
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_autoPanning) {
      _scaleWithNowFixed(details);
    } else {
      _scaleWithFocalPointFixed(details);
    }
    notifyListeners();
  }

  /// Called when user is panning the chart.
  void onPanUpdate(DragUpdateDetails details) {
    rightBoundEpoch -= msFromPx(details.delta.dx);
    notifyListeners();
  }

  /// Called at the end of scale and pan gestures.
  void onScaleAndPanEnd(ScaleEndDetails details) {
    _triggerScrollMomentum(details.velocity);
  }

  void _scaleWithNowFixed(ScaleUpdateDetails details) {
    final nowToRightBound = pxFromMs(rightBoundEpoch - _nowEpoch);
    _scale(details.scale);
    rightBoundEpoch = _nowEpoch + msFromPx(nowToRightBound);
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = width - details.focalPoint.dx;
    final focalEpoch = rightBoundEpoch - msFromPx(focalToRightBound);
    _scale(details.scale);
    rightBoundEpoch = focalEpoch + msFromPx(focalToRightBound);
  }

  void _scale(double scale) {
    msPerPx = (_prevMsPerPx / scale).clamp(_minScale, _maxScale);
  }

  /// Animate scrolling to current tick.
  void scrollToNow() {
    const duration = Duration(milliseconds: 600);
    final target = _maxRightBoundEpoch + duration.inMilliseconds;

    _rightEpochAnimationController
      ..value = rightBoundEpoch.toDouble()
      ..animateTo(
        target.toDouble(),
        curve: Curves.easeOut,
        duration: duration,
      );
  }

  void _triggerScrollMomentum(Velocity velocity) {
    final Simulation simulation = ClampingScrollSimulation(
      position: rightBoundEpoch.toDouble(),
      velocity: -velocity.pixelsPerSecond.dx * msPerPx,
      friction: 0.015 * msPerPx,
    );
    _rightEpochAnimationController
      ..value = rightBoundEpoch.toDouble()
      ..animateWith(simulation);
  }
}
