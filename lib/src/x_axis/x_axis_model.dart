import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:flutter/material.dart';

/// State and methods of chart's x-axis.
class XAxisModel extends ChangeNotifier {
  // TODO(Rustem): Add closed contract x-axis constructor.

  /// Creates x-axis model for live chart.
  XAxisModel({
    @required int firstCandleEpoch,
    @required int granularity,
    @required AnimationController animationController,
  }) {
    _nowEpoch = DateTime.now().millisecondsSinceEpoch;
    _firstCandleEpoch = firstCandleEpoch ?? _nowEpoch;
    _granularity = granularity ?? 0;
    _msPerPx = _defaultScale;
    rightBoundEpoch = _maxRightBoundEpoch;

    _rightEpochAnimationController = animationController
      ..addListener(() {
        rightBoundEpoch = _rightEpochAnimationController.value.toInt();
        if (hasHitLimit) {
          _rightEpochAnimationController.stop();
        }
      });
  }

  // TODO(Rustem): Expose this setting
  /// Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;

  // TODO(Rustem): Expose this setting
  /// Scaling will not resize intervals to be smaller than this.
  static const int minIntervalWidth = 4;

  // TODO(Rustem): Expose this setting
  /// Scaling will not resize intervals to be bigger than this.
  static const int maxIntervalWidth = 80;

  // TODO(Rustem): Expose this setting
  /// Default to this interval width on granularity change.
  static const int defaultIntervalWidth = 20;

  /// Canvas width.
  double width;

  AnimationController _rightEpochAnimationController;
  bool _autoPanEnabled = true;
  double _msPerPx = 1000;
  double _prevMsPerPx;
  int _firstCandleEpoch;
  int _granularity;
  int _nowEpoch;
  int _rightBoundEpoch;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

  /// Epoch value of the leftmost chart's edge.
  int get leftBoundEpoch => rightBoundEpoch - msFromPx(width);

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  int get rightBoundEpoch => _rightBoundEpoch;

  set rightBoundEpoch(int rightBoundEpoch) {
    _rightBoundEpoch = rightBoundEpoch.clamp(
      _minRightBoundEpoch,
      _maxRightBoundEpoch,
    );
  }

  /// Current scrolling lower bound.
  int get _minRightBoundEpoch =>
      _firstCandleEpoch + msFromPx(maxCurrentTickOffset);

  /// Current scrolling upper bound.
  int get _maxRightBoundEpoch => _nowEpoch + msFromPx(maxCurrentTickOffset);

  /// Has hit left or right panning limit.
  bool get hasHitLimit =>
      rightBoundEpoch == _maxRightBoundEpoch ||
      rightBoundEpoch == _minRightBoundEpoch;

  /// Chart pan is currently being animated (without user input).
  bool get animatingPan =>
      _autoPanning || (_rightEpochAnimationController?.isAnimating ?? false);

  /// Current tick is visible, chart is being autopanned.
  bool get _autoPanning => _autoPanEnabled && rightBoundEpoch > _nowEpoch;

  /// Current scale value.
  double get msPerPx => _msPerPx;

  /// Bounds and default for [_msPerPx].
  double get _minScale => _granularity / maxIntervalWidth;
  double get _maxScale => _granularity / minIntervalWidth;
  double get _defaultScale => _granularity / defaultIntervalWidth;

  /// Updates left panning limit.
  void updateFirstCandleEpoch(int firstCandleEpoch) {
    _firstCandleEpoch = firstCandleEpoch ?? _nowEpoch;
  }

  /// Called on each frame.
  /// Updates right panning limit and autopan if enabled.
  void onNewFrame(Duration _) {
    final newNowEpoch = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = newNowEpoch - _nowEpoch;
    _nowEpoch = newNowEpoch;
    if (_autoPanning) {
      rightBoundEpoch += elapsedMs;
    }
    notifyListeners();
  }

  /// Resets scale and pan on granularity change.
  void updateGranularity(int newGranularity) {
    if (newGranularity == null || _granularity == newGranularity) return;
    _granularity = newGranularity;
    _msPerPx = _defaultScale;
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
  /// TODO(Rustem): Replace with shiftEpochByPx
  int msFromPx(double px) => pxToMs(px, msPerPx: _msPerPx);

  /// Convert ms to px using current scale.
  /// TODO(Rustem): Replace with pxBetween
  double pxFromMs(int ms) => msToPx(ms, msPerPx: _msPerPx);

  /// Px distance between epochs on the chart (time gaps are removed).
  double pxBetween(int leftEpoch, int rightEpoch) => timeRangePxWidth(
        range: TimeRange(leftEpoch, rightEpoch),
        msPerPx: _msPerPx,
        gaps: <TimeRange>[],
      );

  /// Get x position of epoch.
  double xFromEpoch(int epoch) => epochToCanvasX(
        epoch: epoch,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: width,
        msPerPx: _msPerPx,
      );

  /// Get epoch of x position.
  int epochFromX(double x) => canvasXToEpoch(
        x: x,
        rightBoundEpoch: rightBoundEpoch,
        canvasWidth: width,
        msPerPx: _msPerPx,
      );

  /// Called at the start of scale and pan gestures.
  void onScaleAndPanStart(ScaleStartDetails details) {
    _rightEpochAnimationController.stop();
    _prevMsPerPx = _msPerPx;
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
    final nowToRightBound = pxBetween(_nowEpoch, rightBoundEpoch);
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
    _msPerPx = (_prevMsPerPx / scale).clamp(_minScale, _maxScale);
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
      velocity: -velocity.pixelsPerSecond.dx * _msPerPx,
      friction: 0.015 * _msPerPx,
    );
    _rightEpochAnimationController
      ..value = rightBoundEpoch.toDouble()
      ..animateWith(simulation);
  }
}
