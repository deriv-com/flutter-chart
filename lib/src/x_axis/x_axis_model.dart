import 'dart:math';

import 'package:deriv_chart/src/logic/conversion.dart';
import 'package:deriv_chart/src/logic/find_gaps.dart';
import 'package:deriv_chart/src/models/time_range.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Will stop auto-panning when the last tick has reached to this offset from the [XAxisModel.leftBoundEpoch]
const double autoPanOffset = 30;

/// Modes that control chart's zoom and scroll behaviour without user interaction.
enum ViewingMode {
  /// Keeps current tick visible.
  ///
  /// This mode is enabled when [isLive] is `true` and current tick is visible.
  /// It works by keeping the x coordinate of `DateTime.now().millisecondsSinceEpoch` constant.
  /// Meaning, if a line is drawn at `DateTime.now().millisecondsSinceEpoch`
  /// on each frame in this mode, it will appear stationary.
  followCurrentTick,

  /// Keeps all of the data visible.
  ///
  /// This mode is used for contract details.
  fitData,

  /// Keeps scrolling left or right with constant speed.
  ///
  /// Negative speed scrolls the chart back, positive scrolls forward.
  constantScrollSpeed,
}

/// State and methods of chart's x-axis.
class XAxisModel extends ChangeNotifier {
  // TODO(Rustem): Add closed contract x-axis constructor.

  /// Creates x-axis model for live chart.
  XAxisModel({
    @required List<Tick> entries,
    @required int granularity,
    @required AnimationController animationController,
    @required bool isLive,
    this.onScale,
    this.onScroll,
  }) {
    _nowEpoch = DateTime.now().millisecondsSinceEpoch;
    _granularity = granularity ?? 0;
    _msPerPx = _defaultScale;
    _isLive = isLive ?? true;
    _rightBoundEpoch = _maxRightBoundEpoch;

    _updateEntries(entries);

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
  int _granularity;
  int _nowEpoch;
  int _rightBoundEpoch;

  int get _firstCandleEpoch =>
      _entries.isNotEmpty ? _entries.first.epoch : _nowEpoch;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

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
  double get _minScale => _granularity / maxIntervalWidth;

  double get _maxScale => _granularity / minIntervalWidth;

  double get _defaultScale => _granularity / defaultIntervalWidth;

  double _panSpeed;

  /// Updates scrolling bounds and time gaps based on the main chart's entries.
  ///
  /// Should be called after [_updateGranularity] and [_updateIsLive].
  void _updateEntries(List<Tick> entries) {
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

    // Max difference between consecutive entries in milliseconds.
    final int maxDiff = max(
      granularity,
      // Time gap cannot be shorter than this.
      const Duration(minutes: 1).inMilliseconds,
    );

    if (firstLoad || reload) {
      _timeGaps = findGaps(entries, maxDiff);
    } else if (historyLoad) {
      // ------------- entries
      //         ----- _entries
      // ---------     prefix
      //        ↑↑
      //        AB
      // include B in prefix to detect gaps between A and B
      final List<Tick> prefix =
          entries.sublist(0, entries.length - _entries.length + 1);
      _timeGaps = findGaps(prefix, maxDiff) + _timeGaps;
    }

    // Sublist, so that [_entries] references the old list when [entries] is modified in place.
    _entries = entries.sublist(0);

    // After switching between closed and open symbols, since their epoch range might
    // be without any overlap, scroll position on the new symbol might be completely off
    // where there is no data hence the chart will show just a loading animation.
    // Here we make sure that it's on-range.
    _clampRightBoundEpoch();
  }

  /// Resets scale and pan on granularity change.
  ///
  /// Should be called before [_updateEntries] and after [_updateIsLive]
  void _updateGranularity(int newGranularity) {
    if (newGranularity == null || _granularity == newGranularity) return;
    _granularity = newGranularity;
    _msPerPx = _defaultScale;
    _scrollTo(_maxRightBoundEpoch);
  }

  /// Update's chart's isLive property
  ///
  /// Should be called before [_updateGranularity] and [_updateEntries]
  void _updateIsLive(bool isLive) => _isLive = isLive ?? true;

  /// Called on each frame.
  /// Updates right panning limit and autopan if enabled.
  void onNewFrame(Duration _) {
    final newNowEpoch = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = newNowEpoch - _nowEpoch;
    _nowEpoch = newNowEpoch;
    if (_autoPanning) {
      _scrollTo(_rightBoundEpoch + elapsedMs);
    } else if (_panSpeed != null && _panSpeed != 0) {
      _scrollBy(_panSpeed * elapsedMs);
    }
    notifyListeners();
  }

  void pan(double panSpeed) => _panSpeed = panSpeed ?? 0;

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
    _rightBoundEpoch = rightBoundEpoch;
    _clampRightBoundEpoch();
    onScroll?.call();
  }

  void _scrollBy(double pxShift) {
    _rightBoundEpoch = _shiftEpoch(_rightBoundEpoch, pxShift);
    _clampRightBoundEpoch();
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
    _rightBoundEpoch += 1;
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

  /// Keeps rightBoundEpoch in the valid range
  void _clampRightBoundEpoch() => _rightBoundEpoch =
      _rightBoundEpoch.clamp(_minRightBoundEpoch, _maxRightBoundEpoch);

  /// Updates the [XAxisModel] model variables.
  void update({bool isLive, int granularity, List<Tick> entries}) {
    _updateIsLive(isLive);
    _updateGranularity(granularity);
    _updateEntries(entries);
  }
}
