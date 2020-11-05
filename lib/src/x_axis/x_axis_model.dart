import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:deriv_chart/src/logic/find_gaps.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
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
    @required ChartConfig chartConfig,
    @required AnimationController animationController,
    @required bool isLive,
    this.onScale,
    this.onScroll,
  }) {
    _nowEpoch = DateTime.now().millisecondsSinceEpoch;
    _chartConfig = chartConfig ?? 0;
    _msPerPx = _defaultScale;
    _isLive = isLive ?? true;
    _rightBoundEpoch = _maxRightBoundEpoch;

    updateEntries(entries);

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

  bool _isLive;

  /// Whether the chart is live.
  bool get isLive => _isLive;

  /// Canvas width.
  double width;

  /// Called on scale.
  final VoidCallback onScale;

  /// Called on scroll.
  final VoidCallback onScroll;

  List<Tick> _entries;
  List<TimeRange> _timeGaps = <TimeRange>[];
  AnimationController _scrollAnimationController;
  double _prevScrollAnimationValue;
  bool _autoPanEnabled = true;
  double _msPerPx = 1000;
  double _prevMsPerPx;
  ChartConfig _chartConfig;
  int _nowEpoch;
  int _rightBoundEpoch;

  int get _firstCandleEpoch =>
      _entries.isNotEmpty ? _entries.first.epoch : _nowEpoch;

  /// Difference in milliseconds between two consecutive candles/points.
  ChartConfig get chartConfig => _chartConfig;

  /// Epoch value of the leftmost chart's edge.
  int get leftBoundEpoch => _shiftEpoch(rightBoundEpoch, -width);

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  int get rightBoundEpoch => _rightBoundEpoch;

  /// Current scrolling lower bound.
  int get _minRightBoundEpoch =>
      _shiftEpoch(_firstCandleEpoch, maxCurrentTickOffset);

  /// Current scrolling upper bound.
  int get _maxRightBoundEpoch => _shiftEpoch(
        _entries == null || _entries.isEmpty || _isLive
            ? _nowEpoch
            : _entries.last.epoch,
        maxCurrentTickOffset,
      );

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
      isLive &&
      rightBoundEpoch > _nowEpoch &&
      _currentTickFarEnoughFromLeftBound;

  bool get _currentTickFarEnoughFromLeftBound =>
      _entries.isEmpty ||
      _entries.last.epoch > _shiftEpoch(leftBoundEpoch, autoPanOffset);

  /// Current scale value.
  double get msPerPx => _msPerPx;

  /// Bounds and default for [_msPerPx].
  double get _minScale => _chartConfig.granularity / maxIntervalWidth;

  double get _maxScale => _chartConfig.granularity / minIntervalWidth;

  double get _defaultScale => _chartConfig.granularity / defaultIntervalWidth;

  /// Updates scrolling bounds and time gaps based on the main chart's entries.
  ///
  /// Should be called after [updateGranularity].
  void updateEntries(List<Tick> entries) {
    final bool firstLoad = _entries == null;

    final bool tickLoad = !firstLoad &&
        entries.length >= 2 &&
        _entries.isNotEmpty &&
        entries[entries.length - 2] == _entries.last;

    final bool historyLoad = !firstLoad &&
        entries.isNotEmpty &&
        _entries.isNotEmpty &&
        entries.first != _entries.first &&
        entries.last == _entries.last;

    final bool reload = !firstLoad && !tickLoad && !historyLoad;

    if (firstLoad || reload) {
      _timeGaps = findGaps(entries, _chartConfig.granularity);
    } else if (historyLoad) {
      // ------------- entries
      //         ----- _entries
      // ---------     prefix
      //        ↑↑
      //        AB
      // include B in prefix to detect gaps between A and B
      final List<Tick> prefix =
          entries.sublist(0, entries.length - _entries.length + 1);
      _timeGaps = findGaps(prefix, _chartConfig.granularity) + _timeGaps;
    }

    // Sublist, so that [_entries] references the old list when [entries] is modified in place.
    _entries = entries.sublist(0);
  }

  /// Resets scale and pan on granularity change.
  ///
  /// Should be called before [updateEntries].
  void updateChartConfig(ChartConfig newConfig) {
    if (newConfig == null) return;

    final bool granularityChanged =
        _chartConfig.granularity != newConfig.granularity;
    _chartConfig = newConfig;

    if (!granularityChanged) return;

    _msPerPx = _defaultScale;
    _scrollTo(_maxRightBoundEpoch);
  }

  /// Update's chart's isLive property
  void updateIsLive(bool isLive) => _isLive = isLive ?? true;

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
  double pxFromMs(int ms) => ms / _msPerPx;

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
  int _shiftEpoch(int epoch, double pxShift) => shiftEpochByPx(
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
  int epochFromX(double x) => _shiftEpoch(rightBoundEpoch, -width + x);

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
    _rightBoundEpoch = _shiftEpoch(_nowEpoch, nowToRightBound);
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final focalToRightBound = width - details.focalPoint.dx;
    final focalEpoch = _shiftEpoch(rightBoundEpoch, -focalToRightBound);
    _scale(details.scale);
    _rightBoundEpoch = _shiftEpoch(focalEpoch, focalToRightBound);
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
    _rightBoundEpoch = _shiftEpoch(_rightBoundEpoch, pxShift).clamp(
      _minRightBoundEpoch,
      _maxRightBoundEpoch,
    );
    onScroll?.call();
  }

  /// Animate scrolling to current tick.
  void scrollToLastTick({bool animate = true}) {
    final duration =
        animate ? const Duration(milliseconds: 600) : Duration.zero;
    final target = _maxRightBoundEpoch + duration.inMilliseconds;
    final double distance = target > _rightBoundEpoch
        ? pxBetween(_rightBoundEpoch, target)
        : pxBetween(target, _rightBoundEpoch);

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
