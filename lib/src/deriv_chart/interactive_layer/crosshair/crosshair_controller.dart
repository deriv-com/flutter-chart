import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Represents the immutable state of the crosshair at any given moment.
///
/// This class encapsulates all the information needed to render and manage
/// the crosshair's current state, including its position, visibility, and
/// the data it's currently highlighting.
class CrosshairState {
  /// Creates a new crosshair state with the specified parameters.
  CrosshairState({
    this.crosshairTick,
    this.cursorPosition = Offset.zero,
    this.isVisible = false,
    this.showDetails = true,
    this.isTickWithinDataRange = true,
  });

  /// The tick data point currently being highlighted by the crosshair.
  ///
  /// Can be either a [Tick] for line charts or a [Candle] for candlestick charts.
  /// For positions outside the data range, this may contain a virtual tick.
  final Tick? crosshairTick;

  /// The current position of the cursor in local widget coordinates.
  final Offset cursorPosition;

  /// Whether the crosshair should be visible and rendered on the chart.
  final bool isVisible;

  /// Whether to display the detailed data popup/tooltip alongside the crosshair.
  final bool showDetails;

  /// Indicates whether the current tick represents actual data from the series.
  ///
  /// `true` for actual data, `false` for virtual/synthetic ticks created
  /// for cursor positions outside the data range.
  final bool isTickWithinDataRange;

  /// Creates a copy of this state with the given fields replaced.
  CrosshairState copyWith({
    Tick? crosshairTick,
    Offset? cursorPosition,
    bool? isVisible,
    bool? showDetails,
    bool? isTickWithinDataRange,
  }) {
    return CrosshairState(
      crosshairTick: crosshairTick,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      isVisible: isVisible ?? this.isVisible,
      showDetails: showDetails ?? this.showDetails,
      isTickWithinDataRange:
          isTickWithinDataRange ?? this.isTickWithinDataRange,
    );
  }
}

/// Controller that manages all crosshair functionality and user interactions.
///
/// Handles gesture recognition, data point finding, state management, and
/// coordinate transformations. Extends [ValueNotifier] to provide reactive
/// updates to UI components.
///
/// Key features:
/// - Long press and hover gesture handling
/// - Smart data point finding with virtual tick support
/// - Auto-panning when dragging near chart edges
/// - Velocity-based animation timing
class CrosshairController extends ValueNotifier<CrosshairState> {
  /// Creates a new crosshair controller with the specified configuration.
  CrosshairController({
    required this.xAxisModel,
    required this.series,
    required this.showCrosshair,
    required this.crosshairVariant,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.isCrosshairActive = false,
    this.quoteFromCanvasY,
  }) : super(CrosshairState());

  /// The X-axis model responsible for time-to-position coordinate transformations.
  final XAxisModel xAxisModel;

  /// The data series containing the chart's tick/candle data.
  DataSeries<Tick> series;

  /// Master switch to enable or disable all crosshair functionality.
  final bool showCrosshair;

  /// The variant of the crosshair to be used.
  CrosshairVariant crosshairVariant;

  /// Callback invoked when the crosshair becomes visible.
  final VoidCallback? onCrosshairAppeared;

  /// Callback invoked when the crosshair is hidden.
  final VoidCallback? onCrosshairDisappeared;

  /// Indicates whether the crosshair is currently in an active interaction state.
  bool isCrosshairActive;

  /// Function to convert canvas Y coordinates to quote/price values.
  ///
  /// Essential for creating virtual data points when the cursor is outside
  /// the actual data range.
  final double Function(double)? quoteFromCanvasY;

  /// Tracks the last long press position for clamping and auto-panning logic.
  double? _lastLongPressPosition;

  /// Tracks the epoch corresponding to the last long press position.
  int _lastLongPressPositionEpoch = -1;

  /// The distance from chart edges that triggers auto-panning.
  static const double _closeDistance = 60;

  /// Timer to track the start time of drag operations for velocity calculations.
  DateTime? _timer;

  /// VelocityTracker for more accurate drag velocity measurements.
  final VelocityTracker _dragVelocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  /// Current drag velocity estimate for the crosshair interaction.
  VelocityEstimate _dragVelocity = const VelocityEstimate(
      confidence: 1,
      pixelsPerSecond: Offset.zero,
      duration: Duration.zero,
      offset: Offset.zero);

  /// Calculates the appropriate animation duration based on current drag velocity.
  ///
  /// This getter provides velocity-adaptive animation timing to create smooth,
  /// responsive crosshair interactions. The duration is inversely related to
  /// the drag velocity - faster movements get shorter animations for immediate
  /// feedback, while slower movements get longer animations for smoothness.
  ///
  /// Duration mapping:
  /// - **No movement** (velocity = 0): 5ms (immediate)
  /// - **Very fast** (velocity > 3000 px/s): 5ms (immediate)
  /// - **Slow** (velocity < 500 px/s): 80ms (smooth)
  /// - **Medium** (500-3000 px/s): Linear interpolation between 80ms and 5ms
  ///
  /// The calculation uses only the horizontal (X) component of velocity since
  /// crosshair interactions are primarily concerned with time-based navigation.
  ///
  /// Returns the calculated [Duration] for use in chart animations and transitions.
  Duration get animationDuration {
    double dragXVelocity;

    dragXVelocity = _dragVelocity.pixelsPerSecond.dx.abs().roundToDouble();

    if (dragXVelocity == 0) {
      return const Duration(milliseconds: 5);
    }

    if (dragXVelocity > 3000) {
      return const Duration(milliseconds: 5);
    }

    if (dragXVelocity < 500) {
      return const Duration(milliseconds: 80);
    }

    final double durationInRange = (dragXVelocity - 500) / (2500) * 75 + 5;
    return Duration(milliseconds: durationInRange.toInt());
  }

  /// Handles the start of a long press gesture to activate the crosshair.
  void onLongPressStart(LongPressStartDetails details) {
    onCrosshairAppeared?.call();

    xAxisModel.disableAutoPan();

    _lastLongPressPosition = details.localPosition.dx;
    _updatePanSpeed(_lastLongPressPosition!);
    _timer = DateTime.now();

    final double x = details.localPosition.dx;
    final int epoch = xAxisModel.epochFromX(x);
    final Tick? tick = _findClosestTick(epoch);

    if (tick != null) {
      _showCrosshair(tick, details.localPosition);
    }
  }

  /// Handles updates during a long press drag to move the crosshair.
  void onLongPressUpdate(LongPressMoveUpdateDetails details) {
    if (_timer != null) {
      _lastLongPressPosition = details.localPosition.dx;

      final DateTime now = DateTime.now();
      final Duration passedTime = now.difference(_timer!);
      _timer = DateTime.now();
      _dragVelocityTracker.addPosition(passedTime, details.localPosition);
      _dragVelocity = _dragVelocityTracker.getVelocityEstimate()!;

      _updatePanSpeed(_lastLongPressPosition!);

      final Tick? tick = updateAndFindClosestTick();
      if (tick != null) {
        _showCrosshair(tick, details.localPosition);
      }
    }
  }

  /// Handles the end of a long press gesture to deactivate the crosshair.
  void onLongPressEnd(LongPressEndDetails details) {
    if (details.velocity != Velocity.zero) {
      _dragVelocity = VelocityEstimate(
        confidence: 1,
        pixelsPerSecond: details.velocity.pixelsPerSecond,
        duration: const Duration(milliseconds: 1),
        offset: Offset.zero,
      );
    }

    onCrosshairDisappeared?.call();
    xAxisModel
      ..pan(0)
      ..enableAutoPan();

    _lastLongPressPosition = null;
    _lastLongPressPositionEpoch = -1;

    _hideCrosshair();
  }

  /// Handles mouse hover events to show crosshair on desktop/web platforms.
  void onHover(PointerHoverEvent event) {
    final double x = event.localPosition.dx;
    final double y = event.localPosition.dy;
    final int epoch = xAxisModel.epochFromX(x);
    final Tick? tick = _findTickForCrosshair(epoch: epoch, y: y);

    if (tick != null) {
      _showCrosshair(tick, event.localPosition);
    }

    notifyListeners();
  }

  /// Handles mouse exit events to hide crosshair when cursor leaves the chart.
  void onExit(PointerExitEvent event) {
    _hideCrosshair();
  }

  /// Hides the crosshair and resets the interaction state.
  void _hideCrosshair() {
    if (value.isVisible) {
      onCrosshairDisappeared?.call();
    }

    value = value.copyWith(
      isVisible: false,
    );

    isCrosshairActive = false;
    notifyListeners();
  }

  /// Shows the crosshair with the specified tick data and cursor position.
  void _showCrosshair(Tick crosshairTick, Offset position) {
    if (!showCrosshair) {
      return;
    }

    if (!value.isVisible) {
      onCrosshairAppeared?.call();
    }

    final bool isWithinRange = _isCursorWithinDataRange(
      crosshairTick.epoch,
      series.visibleEntries.entries,
    );

    value = value.copyWith(
      crosshairTick: crosshairTick,
      cursorPosition: position,
      isVisible: true,
      isTickWithinDataRange: isWithinRange,
    );
    isCrosshairActive = true;
    notifyListeners();
  }

  /// Finds the closest tick to the specified epoch timestamp.
  Tick? _findClosestTick(int epoch) {
    return findClosestToEpoch(epoch, series.visibleEntries.entries);
  }

  /// Gets the closest tick based on the current position with position clamping and epoch tracking.
  Tick? updateAndFindClosestTick([double? cursorX]) {
    final double? _targetPosition = cursorX ?? _lastLongPressPosition;
    if (_targetPosition == null) {
      return null;
    }

    // Clamp the position to stay within close distance boundaries
    // This prevents the crosshair from getting too close to the chart edges
    final double clampedPosition = _targetPosition.clamp(
        _closeDistance, xAxisModel.width! - _closeDistance);

    // Convert the clamped position to epoch time
    final int newLongPressEpoch = xAxisModel.epochFromX(clampedPosition);

    // Only update closest tick if position epoch has changed
    // This optimization prevents unnecessary tick lookups
    if (newLongPressEpoch != _lastLongPressPositionEpoch) {
      _lastLongPressPositionEpoch = newLongPressEpoch;
    }

    // Find and return the closest tick for the current epoch
    return _findTickForCrosshair(epoch: _lastLongPressPositionEpoch);
  }

  /// Finds the appropriate tick for crosshair display based on cursor position.
  ///
  /// Snaps to closest data point if within range, otherwise creates virtual tick.
  Tick? _findTickForCrosshair({required int epoch, double y = 0}) {
    final List<Tick> entries = series.visibleEntries.entries;

    if (entries.isEmpty) {
      return null;
    }

    // Check if cursor is within the data range
    final bool isWithinDataRange = _isCursorWithinDataRange(epoch, entries);
    if (isWithinDataRange || crosshairVariant == CrosshairVariant.smallScreen) {
      // Within data range: snap to closest tick
      return _findClosestTick(epoch);
    } else {
      // Outside data range: create virtual tick using cursor's Y position for quote
      final double quote = quoteFromCanvasY!(y);

      return series.createVirtualTick(epoch, quote);
    }
  }

  /// Determines whether the cursor position falls within the actual data range.
  bool _isCursorWithinDataRange(int epoch, List<Tick> entries) {
    if (entries.isEmpty) {
      return false;
    }

    final int firstEpoch = entries.first.epoch;
    final int lastEpoch = entries.last.epoch;

    // Consider cursor within range if it's between first and last tick epochs
    return epoch >= firstEpoch && epoch <= lastEpoch;
  }

  /// Updates the chart panning speed based on cursor proximity to chart edges.
  void _updatePanSpeed(double x) {
    const double panSpeed = 0.08;

    if (x < _closeDistance) {
      xAxisModel.pan(-panSpeed);
    } else if (xAxisModel.width! - x < _closeDistance) {
      xAxisModel.pan(panSpeed);
    } else {
      xAxisModel.pan(0);
    }
  }
}
