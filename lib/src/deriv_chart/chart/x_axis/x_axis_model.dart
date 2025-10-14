// ignore_for_file: unnecessary_getters_setters

import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/time_range.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/functions/snap_epoch.dart';
import 'functions/calc_no_overlay_time_gaps.dart';
import 'gaps/gap_manager.dart';
import 'gaps/helpers.dart';
import 'grid/calc_time_grid.dart';

/// Will stop auto-panning when the last tick has reached to this offset from
/// the [XAxisModel.leftBoundEpoch].
const double autoPanOffset = 30;

/// Padding around data used in data-fit mode.
const EdgeInsets defaultDataFitPadding = EdgeInsets.only(left: 16, right: 120);

/// Modes that control chart's zoom and scroll behaviour without user
/// interaction.
enum ViewingMode {
  /// Keeps current tick visible.
  ///
  /// This mode is enabled when `isLive` is `true` and current tick is visible.
  /// It works by keeping the x coordinate of
  /// `DateTime.now().millisecondsSinceEpoch` constant.
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

  /// Scroll and zoom only change with user gestures.
  stationary,
}

/// State and methods of chart's x-axis.
class XAxisModel extends ChangeNotifier {
  /// Creates x-axis model for live chart.
  XAxisModel({
    required List<Tick> entries,
    required int granularity,
    required AnimationController animationController,
    required bool isLive,
    required bool snapMarkersToIntervals,
    required double maxCurrentTickOffset,
    this.defaultIntervalWidth = 20,
    bool startWithDataFitMode = false,
    int? minEpoch,
    int? maxEpoch,
    double? msPerPx,
    double? minIntervalWidth,
    double? maxIntervalWidth,
    EdgeInsets? dataFitPadding,
    this.onScale,
    this.onScroll,
  }) {
    _maxCurrentTickOffset = maxCurrentTickOffset;
    _snapMarkersToIntervals = snapMarkersToIntervals;

    _nowEpoch = entries.isNotEmpty
        ? entries.last.epoch
        : DateTime.now().millisecondsSinceEpoch;

    _minEpoch =
        minEpoch ?? (entries.isNotEmpty ? entries.first.epoch : _nowEpoch);
    _maxEpoch =
        maxEpoch ?? (entries.isNotEmpty ? entries.last.epoch : _nowEpoch);

    _lastEpoch = DateTime.now().millisecondsSinceEpoch;
    _granularity = granularity;
    _msPerPx = msPerPx ?? _defaultMsPerPx;
    _isLive = isLive;
    _maxCurrentTickOffset = maxCurrentTickOffset;
    _rightBoundEpoch = _maxRightBoundEpoch;
    _dataFitMode = startWithDataFitMode;
    _minIntervalWidth = minIntervalWidth ?? 1;
    _maxIntervalWidth = maxIntervalWidth ?? 80;

    _dataFitPadding = dataFitPadding ?? defaultDataFitPadding;

    _updateEntries(entries);

    _scrollAnimationController = animationController
      ..addListener(() {
        final double diff =
            _scrollAnimationController.value - (_prevScrollAnimationValue ?? 0);
        scrollBy(diff);

        if (hasHitLimit) {
          _scrollAnimationController.stop();
        }
        _prevScrollAnimationValue = _scrollAnimationController.value;
      });
  }

  late double _minIntervalWidth;

  late double _maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  late EdgeInsets _dataFitPadding;

  /// Default to this interval width on granularity change.
  final double defaultIntervalWidth;

  /// Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
  /// Limits panning to the right.
  double _maxCurrentTickOffset = 200;

  late bool _isLive;

  /// for calculating time between two frames
  late int _lastEpoch;

  /// Whether the chart is live.
  bool get isLive => _isLive;

  /// Canvas width.
  double? width;

  /// Canvas width, excluding the Y-axis labels area.
  double? graphAreaWidth;

  /// Right padding that is applied on the x-axis, the space which is preserved
  /// for y-axis labels
  double? get rightPadding =>
      width != null && graphAreaWidth != null ? width! - graphAreaWidth! : null;

  /// Called on scale.
  final VoidCallback? onScale;

  /// Called on scroll.
  final VoidCallback? onScroll;

  List<Tick>? _entries;

  late int _minEpoch, _maxEpoch;

  final GapManager _gapManager = GapManager();
  late AnimationController _scrollAnimationController;
  double? _prevScrollAnimationValue;
  bool _autoPanEnabled = true;
  late bool _dataFitMode;
  double _msPerPx = 1000;
  double? _prevMsPerPx;
  late int _granularity;
  late bool _snapMarkersToIntervals;
  late bool _isScrollBlocked = false;
  late int _nowEpoch;
  late int _rightBoundEpoch;
  double _panSpeed = 0;

  /// Difference in milliseconds between two consecutive candles/points.
  int get granularity => _granularity;

  /// Whether horizontal scroll is blocked.
  bool get isScrollBlocked => _isScrollBlocked;

  set isScrollBlocked(bool value) => _isScrollBlocked = value;

  /// Epoch value of the leftmost chart's edge.
  int get leftBoundEpoch => _shiftEpoch(rightBoundEpoch, -width!);

  /// Epoch value of the rightmost chart's edge. Including quote labels area.
  int get rightBoundEpoch => _rightBoundEpoch;

  set rightBoundEpoch(int value) => _rightBoundEpoch = value;

  /// Current scrolling lower bound.
  int get _minRightBoundEpoch => _shiftEpoch(_minEpoch, _maxCurrentTickOffset);

  /// Current scrolling upper bound.
  int get _maxRightBoundEpoch => _shiftEpoch(_maxEpoch, _maxCurrentTickOffset);

  /// Has hit left or right panning limit.
  bool get hasHitLimit =>
      rightBoundEpoch == _maxRightBoundEpoch ||
      rightBoundEpoch == _minRightBoundEpoch;

  bool get _followCurrentTick =>
      _autoPanEnabled &&
      isLive &&
      rightBoundEpoch > _nowEpoch &&
      _currentTickFarEnoughFromLeftBound;

  bool get _currentTickFarEnoughFromLeftBound =>
      _entries!.isEmpty ||
      _entries!.last.epoch > _shiftEpoch(leftBoundEpoch, autoPanOffset);

  /// Current scale value.
  double get msPerPx => _msPerPx;

  /// Min value for [_msPerPx]. Limits zooming in.
  double get _minMsPerPx => _granularity / _maxIntervalWidth;

  /// Max value for [_msPerPx]. Limits zooming out.
  double get _maxMsPerPx => _granularity / _minIntervalWidth;

  /// Starting value for [_msPerPx].
  double get _defaultMsPerPx => _granularity / defaultIntervalWidth;

  /// Whether data fit mode is enabled.
  /// Doesn't mean it is currently active viewing mode.
  /// Check [_currentViewingMode].
  bool get dataFitEnabled => _dataFitMode;

  /// Current mode that controls chart's zooming and scrolling behaviour.
  ViewingMode get _currentViewingMode {
    if (_panSpeed != 0) {
      return ViewingMode.constantScrollSpeed;
    }
    if (_dataFitMode) {
      return ViewingMode.fitData;
    }
    if (_followCurrentTick) {
      return ViewingMode.followCurrentTick;
    }
    return ViewingMode.stationary;
  }

  /// Called on each tick's curve animation
  /// Updates scroll position if the [_currentViewingMode] in follow mode.
  void scrollAnimationListener(int offsetEpoch) {
    _nowEpoch = (_entries?.isNotEmpty ?? false)
        ? _entries!.last.epoch
        : _nowEpoch + offsetEpoch;

    if (_currentViewingMode == ViewingMode.followCurrentTick) {
      _scrollTo(_rightBoundEpoch + offsetEpoch);
    }
  }

  /// Called on each frame.
  /// Updates zoom and scroll position based on current [_currentViewingMode].
  void onNewFrame(Duration _) {
    final int newNowTime = DateTime.now().millisecondsSinceEpoch;
    final int elapsedMs = newNowTime - _lastEpoch;
    _nowEpoch = (_entries?.isNotEmpty ?? false)
        ? _entries!.last.epoch
        : _nowEpoch + elapsedMs;
    // TODO(NA): Consider refactoring the switch with OOP pattern. https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html
    switch (_currentViewingMode) {
      case ViewingMode.followCurrentTick:
        _scrollTo(_rightBoundEpoch + elapsedMs);
        break;
      case ViewingMode.fitData:
        fitAvailableData();
        break;
      case ViewingMode.constantScrollSpeed:
        scrollBy(_panSpeed * elapsedMs);
        break;
      case ViewingMode.stationary:
        break;
    }

    _lastEpoch = newNowTime;
  }

  /// Updates scrolling bounds and time gaps based on the main chart's entries.
  ///
  /// Should be called after [_updateGranularity] and [_updateIsLive].
  void _updateEntries(List<Tick>? entries) {
    if (entries == null) {
      return;
    }
    final bool firstLoad = _entries == null;

    final bool tickLoad = !firstLoad &&
        entries.length >= 2 &&
        _entries!.isNotEmpty &&
        entries[entries.length - 2] == _entries!.last;

    final bool historyLoad = !firstLoad &&
        entries.isNotEmpty &&
        _entries!.isNotEmpty &&
        entries.first != _entries!.first &&
        entries.last == _entries!.last &&
        _entries!.length < entries.length;

    final bool reload = !firstLoad && !tickLoad && !historyLoad;

    // Max difference between consecutive entries in milliseconds.
    final int maxDiff = max(
      granularity,
      // Time gap cannot be shorter than this.
      const Duration(minutes: 1).inMilliseconds,
    );

    if (firstLoad || reload) {
      _gapManager.replaceGaps(findGaps(entries, maxDiff));
    } else if (historyLoad) {
      // ------------- entries
      //         ----- _entries
      // ---------     prefix
      //        ↑↑
      //        AB
      // include B in prefix to detect gaps between A and B
      final List<Tick> prefix =
          entries.sublist(0, entries.length - _entries!.length + 1);
      _gapManager.insertInFront(findGaps(prefix, maxDiff));
    }

    // Sublist, so that [_entries] references the old list when [entries] is
    // modified in place.
    _entries = entries.sublist(0);

    // After switching between closed and open symbols, since their epoch range
    // might be without any overlap, scroll position on the new symbol might be
    // completely off where there is no data hence the chart will show just a
    // loading animation. Here we make sure that it's on-range.
    _clampRightBoundEpoch();
  }

  /// Resets scale and pan on granularity change.
  ///
  /// Should be called before [_updateEntries] and after [_updateIsLive]
  void _updateGranularity(int? newGranularity) {
    if (newGranularity == null || _granularity == newGranularity) {
      return;
    }
    _granularity = newGranularity;
    _msPerPx = _defaultMsPerPx;
    _scrollTo(_maxRightBoundEpoch);
  }

  /// Updates chart's isLive property.
  ///
  /// Should be called before [_updateGranularity] and [_updateEntries]
  void _updateIsLive(bool? isLive) {
    if (isLive == null || _isLive == isLive) {
      return;
    }
    _isLive = isLive;
  }

  /// Fits available data to screen and to disable data fit mode.
  void fitAvailableData() {
    _fitData();

    /// Switch to [ViewingMode.followCurrentTick] once reached zoom out
    /// limit.
    if (_msPerPx == _maxMsPerPx) {
      disableDataFit();
    }
  }

  /// Fits available data to screen.
  void _fitData() {
    if (width != null && (_entries?.isNotEmpty ?? false)) {
      final int lastEntryEpoch = _entries?.last.epoch ?? _nowEpoch;

      // `entries.length * granularity` gives ms duration with market gaps
      // excluded.
      final int msDataDuration = _entries!.length * granularity;
      final double pxTargetDataWidth = width! - _dataFitPadding.horizontal;

      _msPerPx =
          (msDataDuration / pxTargetDataWidth).clamp(_minMsPerPx, _maxMsPerPx);
      _scrollTo(_shiftEpoch(lastEntryEpoch, _dataFitPadding.right));
    }
  }

  /// Enables data fit viewing mode.
  void enableDataFit() {
    _dataFitMode = true;
    if (kIsWeb) {
      fitAvailableData();
    }

    notifyListeners();
  }

  /// Disables data fit viewing mode.
  void disableDataFit() {
    _dataFitMode = false;
    notifyListeners();
  }

  /// Sets [panSpeed] if input not null, otherwise sets to `0`.
  // ignore: use_setters_to_change_properties
  void pan(double panSpeed) => _panSpeed = panSpeed;

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
  ///
  /// [leftEpoch] must be before [rightEpoch].
  double pxBetween(int leftEpoch, int rightEpoch) =>
      _gapManager.removeGaps(TimeRange(leftEpoch, rightEpoch)) / _msPerPx;

  /// Resulting epoch when given epoch value is shifted by given px amount
  /// on X-axis.
  ///
  /// Positive [pxShift] is shifting epoch into the future,
  /// and negative [pxShift] into the past.
  int _shiftEpoch(int epoch, double pxShift) => shiftEpochByPx(
        epoch: epoch,
        pxShift: pxShift,
        msPerPx: _msPerPx,
        gaps: _gapManager.gaps,
      );

  /// Get x position of epoch.
  double xFromEpoch(int epoch) {
    if (epoch <= rightBoundEpoch) {
      return width! - pxBetween(epoch, rightBoundEpoch);
    } else {
      return width! + pxBetween(rightBoundEpoch, epoch);
    }
  }

  /// Returns the x position for the given [epoch], snapped to the center of its granularity bucket.
  ///
  /// This ensures markers are aligned with the center of each candle (granularity bucket),
  /// preventing markers from being drawn between candles.
  double xFromEpochSnapped(int epoch) {
    // Clamp epoch to prevent rendering markers far off-screen, which can impact performance.
    final int clampedEpoch = epoch.clamp(
        leftBoundEpoch - granularity, rightBoundEpoch + granularity);

    if (_snapMarkersToIntervals) {
      return xFromEpoch(snapEpochToGranularity(clampedEpoch, granularity));
    }
    return xFromEpoch(clampedEpoch);
  }

  /// Get epoch of x position.
  int epochFromX(double x) => _shiftEpoch(rightBoundEpoch, -width! + x);

  /// Called at the start of scale and pan gestures.
  void onScaleAndPanStart(ScaleStartDetails details) {
    _scrollAnimationController.stop();
    _prevMsPerPx = _msPerPx;

    // Exit data fit mode.
    disableDataFit();
  }

  /// Called when user is scaling the chart.
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_currentViewingMode == ViewingMode.followCurrentTick) {
      _scaleWithNowFixed(details);
    } else {
      _scaleWithFocalPointFixed(details);
    }
  }

  /// Called when user is panning the chart.
  void onPanUpdate(DragUpdateDetails details) {
    // TODO(Jim): find simpler way to implement this
    if (!_isScrollBlocked) {
      scrollBy(-details.delta.dx);
    }
  }

  /// Called at the end of scale and pan gestures.
  void onScaleAndPanEnd(ScaleEndDetails details) {
    if (!_isScrollBlocked) {
      _triggerScrollMomentum(details.velocity);
    }
  }

  /// Called to scale the chart
  void scale(double scale) {
    _msPerPx = (_prevMsPerPx! / scale).clamp(_minMsPerPx, _maxMsPerPx);
    onScale?.call();
    notifyListeners();
  }

  /// Called to scroll the chart
  void scrollBy(double pxShift) {
    _rightBoundEpoch = _shiftEpoch(_rightBoundEpoch, pxShift);
    _clampRightBoundEpoch();
    onScroll?.call();
    notifyListeners();
  }

  void _scaleWithNowFixed(ScaleUpdateDetails details) {
    final double nowToRightBound = pxBetween(_nowEpoch, rightBoundEpoch);
    scale(details.scale);
    _rightBoundEpoch = _shiftEpoch(_nowEpoch, nowToRightBound);
    _clampRightBoundEpoch();
  }

  void _scaleWithFocalPointFixed(ScaleUpdateDetails details) {
    final double focalToRightBound = width! - details.focalPoint.dx;
    final int focalEpoch = _shiftEpoch(rightBoundEpoch, -focalToRightBound);
    scale(details.scale);
    _rightBoundEpoch = _shiftEpoch(focalEpoch, focalToRightBound);
    _clampRightBoundEpoch();
  }

  void _scrollTo(int rightBoundEpoch) {
    if (width != null && _rightBoundEpoch != rightBoundEpoch) {
      _rightBoundEpoch = rightBoundEpoch;
      _clampRightBoundEpoch();
      onScroll?.call();
      notifyListeners();
    }
  }

  /// Animate scrolling to current tick.
  void scrollToLastTick({bool animate = true}) {
    final Duration duration =
        animate ? const Duration(milliseconds: 600) : Duration.zero;
    final int target = _shiftEpoch(
            // _lastEntryEpoch will be removed later.
            (_entries?.isNotEmpty ?? false) ? _entries!.last.epoch : _nowEpoch,
            _maxCurrentTickOffset) +
        duration.inMilliseconds;

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

  /// Keeps rightBoundEpoch in the valid range.
  void _clampRightBoundEpoch() {
    if (_minRightBoundEpoch <= _maxRightBoundEpoch) {
      _rightBoundEpoch =
          _rightBoundEpoch.clamp(_minRightBoundEpoch, _maxRightBoundEpoch);
    }
  }

  /// Updates the [XAxisModel] model variables.
  void update({
    bool? isLive,
    int? granularity,
    List<Tick>? entries,
    int? minEpoch,
    int? maxEpoch,
    EdgeInsets? dataFitPadding,
    double? maxCurrentTickOffset,
    bool? snapMarkersToIntervals,
  }) {
    _updateIsLive(isLive);
    _updateGranularity(granularity);
    _updateEntries(entries);

    _minEpoch = minEpoch ?? _minEpoch;
    _maxEpoch = maxEpoch ?? _maxEpoch;
    _dataFitPadding = dataFitPadding ?? _dataFitPadding;
    _maxCurrentTickOffset = maxCurrentTickOffset ?? _maxCurrentTickOffset;
    _snapMarkersToIntervals = snapMarkersToIntervals ?? _snapMarkersToIntervals;
  }

  /// Returns a list of timestamps in the grid without any overlaps.
  List<DateTime> getNoOverlapGridTimestamps() {
    const double _minDistanceBetweenTimeGridLines = 80;
    // Calculate time labels' timestamps for current scale.
    final List<DateTime> _gridTimestamps = gridTimestamps(
      timeGridInterval: timeGridInterval(
        pxFromMs,
        minDistanceBetweenLines: _minDistanceBetweenTimeGridLines,
      ),
      leftBoundEpoch: leftBoundEpoch,
      rightBoundEpoch: rightBoundEpoch,
    );
    return calculateNoOverlapGridTimestamps(
      _gridTimestamps,
      _minDistanceBetweenTimeGridLines,
      pxBetween,
      _gapManager.isInGap,
    );
  }
}
