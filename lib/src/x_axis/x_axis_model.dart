import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:deriv_chart/src/models/time_range.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Will stop auto-panning when the last tick has reached to this offset from the [XAxisModel.leftBoundEpoch]
const double autoPanOffset = 30;

/// State and methods of chart's x-axis.
class XAxisModel extends ChangeNotifier {
  // TODO(Rustem): Add closed contract x-axis constructor.

  /// Creates x-axis model for live chart.
  XAxisModel({
    @required List<Tick> entries,
    @required int granularity,
    @required AnimationController animationController,
    this.onScale,
    this.onScroll,
  }) : _entries = entries {
    _nowEpoch = DateTime.now().millisecondsSinceEpoch;
    _granularity = granularity ?? 0;
    _msPerPx = _defaultScale;
    _rightBoundEpoch = _maxRightBoundEpoch;

    _scrollAnimationController = animationController
      ..addListener(() {
        final double diff =
            _scrollAnimationController.value - (_prevScrollAnimationValue ?? 0);
        _scrollBy(diff);

        if (hasHitLimit) {
          _scrollAnimationController.stop();
        }
        _prevScrollAnimationValue = _scrollAnimationController.value;
      });
  }

  List<Tick> _entries;
  List<TimeRange> _timeGaps = [TimeRange(1601430072281, 1601434891491)];

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

  /// Called on scale.
  final VoidCallback onScale;

  /// Called on scroll.
  final VoidCallback onScroll;

  AnimationController _scrollAnimationController;
  double _prevScrollAnimationValue;
  bool _autoPanEnabled = true;
  double _msPerPx = 1000;
  double _prevMsPerPx;
  int _granularity;
  int _nowEpoch;
  int _rightBoundEpoch;

  int get _firstCandleEpoch =>
      _entries.isNotEmpty ? _entries.first.epoch : _nowEpoch;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

  /// Epoch value of the leftmost chart's edge.
  int get leftBoundEpoch => shiftEpoch(rightBoundEpoch, -width);

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  int get rightBoundEpoch => _rightBoundEpoch;

  /// Current scrolling lower bound.
  int get _minRightBoundEpoch =>
      shiftEpoch(_firstCandleEpoch, maxCurrentTickOffset);

  /// Current scrolling upper bound.
  int get _maxRightBoundEpoch => shiftEpoch(_nowEpoch, maxCurrentTickOffset);

  /// Has hit left or right panning limit.
  bool get hasHitLimit =>
      rightBoundEpoch == _maxRightBoundEpoch ||
      rightBoundEpoch == _minRightBoundEpoch;

  /// Chart pan is currently being animated (without user input).
  bool get animatingPan =>
      _autoPanning || (_scrollAnimationController?.isAnimating ?? false);

  /// Current tick is visible, chart is being autoPanned.
  bool get _autoPanning =>
      _autoPanEnabled &&
      rightBoundEpoch > _nowEpoch &&
      _currentTickFarEnoughFromLeftBound;

  bool get _currentTickFarEnoughFromLeftBound =>
      _entries.isEmpty ||
      _entries.last.epoch > shiftEpoch(leftBoundEpoch, autoPanOffset);

  /// Current scale value.
  double get msPerPx => _msPerPx;

  /// Bounds and default for [_msPerPx].
  double get _minScale => _granularity / maxIntervalWidth;

  double get _maxScale => _granularity / minIntervalWidth;

  double get _defaultScale => _granularity / defaultIntervalWidth;

  /// Updates chart's main data
  void updateEntries(List<Tick> entries) => _entries = entries;

  /// Resets scale and pan on granularity change.
  void updateGranularity(int newGranularity) {
    if (newGranularity == null || _granularity == newGranularity) return;
    _granularity = newGranularity;
    _msPerPx = _defaultScale;
    _scrollTo(_maxRightBoundEpoch);
  }

  /// Called on each frame.
  /// Updates right panning limit and autopan if enabled.
  void onNewFrame(Duration _) {
    final newNowEpoch = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = newNowEpoch - _nowEpoch;
    _nowEpoch = newNowEpoch;
    if (_autoPanning) {
      _scrollTo(_rightBoundEpoch + elapsedMs);
    }
    notifyListeners();
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

  /// Convert ms to px using current scale.
  ///
  /// Doesn't take removed time gaps into account. Use [pxBetween] if you need
  /// to measure distance between two timestamps on the chart.
  /// TODO(Rustem): Remove once time grid doesn't depend on it.
  double pxFromMs(int ms) => msToPx(ms, msPerPx: _msPerPx);

  /// Px distance between two epochs on the x-axis.
  double pxBetween(int leftEpoch, int rightEpoch) => timeRangePxWidth(
        range: TimeRange(leftEpoch, rightEpoch),
        msPerPx: _msPerPx,
        gaps: _timeGaps,
      );

  /// Resulting epoch when given epoch value is shifted by given px amount on x-axis.
  ///
  /// Positive [pxShift] is shifting epoch into the future,
  /// and negative [pxShift] into the past.
  int shiftEpoch(int epoch, double pxShift) => shiftEpochByPx(
        epoch: epoch,
        pxShift: pxShift,
        msPerPx: _msPerPx,
        gaps: _timeGaps,
      );

  /// Get x position of epoch.
  double xFromEpoch(int epoch) => epoch <= rightBoundEpoch
      ? width - pxBetween(epoch, rightBoundEpoch)
      : width + pxBetween(rightBoundEpoch, epoch);

  /// Get epoch of x position.
  int epochFromX(double x) => shiftEpoch(rightBoundEpoch, -width + x);

  /// Called at the start of scale and pan gestures.
  void onScaleAndPanStart(ScaleStartDetails details) {
    _scrollAnimationController.stop();
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
    _scrollBy(-details.delta.dx);
    notifyListeners();
  }

  /// Called at the end of scale and pan gestures.
  void onScaleAndPanEnd(ScaleEndDetails details) {
    _triggerScrollMomentum(details.velocity);
  }

  void _scaleWithNowFixed(ScaleUpdateDetails details) {
    final nowToRightBound = pxBetween(_nowEpoch, rightBoundEpoch);
    _scale(details.scale);
    _rightBoundEpoch = shiftEpoch(_nowEpoch, nowToRightBound);
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = width - details.focalPoint.dx;
    final focalEpoch = shiftEpoch(rightBoundEpoch, -focalToRightBound);
    _scale(details.scale);
    _rightBoundEpoch = shiftEpoch(focalEpoch, focalToRightBound);
  }

  void _scale(double scale) {
    _msPerPx = (_prevMsPerPx / scale).clamp(_minScale, _maxScale);
    onScale?.call();
  }

  void _scrollTo(int rightBoundEpoch) {
    _rightBoundEpoch = rightBoundEpoch.clamp(
      _minRightBoundEpoch,
      _maxRightBoundEpoch,
    );
    onScroll?.call();
  }

  void _scrollBy(double pxShift) {
    _rightBoundEpoch = shiftEpoch(_rightBoundEpoch, pxShift).clamp(
      _minRightBoundEpoch,
      _maxRightBoundEpoch,
    );
    onScroll?.call();
  }

  /// Animate scrolling to current tick.
  void scrollToNow() {
    const Duration duration = Duration(milliseconds: 600);
    final int target = _maxRightBoundEpoch + duration.inMilliseconds;
    final double distance = pxBetween(_rightBoundEpoch, target);

    _prevScrollAnimationValue = 0;
    _scrollAnimationController
      ..value = 0
      ..animateTo(
        distance,
        curve: Curves.easeOut,
        duration: duration,
      );
  }

  void _triggerScrollMomentum(Velocity velocity) {
    final Simulation simulation = ClampingScrollSimulation(
      position: 0,
      velocity: -velocity.pixelsPerSecond.dx,
    );
    _prevScrollAnimationValue = 0;
    _scrollAnimationController.animateWith(simulation);
  }
}
