import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/utils/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Represents the state of the crosshair.
class CrosshairState {
  /// Creates a new crosshair state.
  CrosshairState({
    this.crosshairTick,
    this.cursorPosition = Offset.zero,
    this.isVisible = false,
    this.showDetails = true,
  });

  /// The tick to display in the crosshair.
  final Tick? crosshairTick;

  /// The position of the cursor.
  final Offset cursorPosition;

  /// Whether the crosshair is visible.
  final bool isVisible;

  /// Whether to show the details popup.
  final bool showDetails;

  /// Creates a copy of this state with the given fields replaced.
  CrosshairState copyWith({
    Tick? crosshairTick,
    Offset? cursorPosition,
    bool? isVisible,
    bool? showDetails,
  }) {
    return CrosshairState(
      crosshairTick: crosshairTick,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      isVisible: isVisible ?? this.isVisible,
      showDetails: showDetails ?? this.showDetails,
    );
  }
}

/// Controller for the crosshair functionality.
class CrosshairController extends ValueNotifier<CrosshairState> {
  /// Creates a new crosshair controller.
  CrosshairController({
    required this.xAxisModel,
    required this.series,
    required this.showCrosshair,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.isCrosshairActive = false,
  }) : super(CrosshairState());

  /// The X axis model.
  final XAxisModel xAxisModel;

  /// The data series.
  DataSeries<Tick> series;

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  /// Called when the crosshair appears.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair disappears.
  final VoidCallback? onCrosshairDisappeared;

  /// Whether the crosshair is currently active.
  bool isCrosshairActive;

  // Track previous position and time for velocity calculation
  Offset _previousOffset = Offset.zero;
  DateTime _previousTime = DateTime.now();

  VelocityEstimate _dragVelocity = const VelocityEstimate(
      confidence: 1,
      pixelsPerSecond: Offset.zero,
      duration: Duration.zero,
      offset: Offset.zero);

  /// Updates the drag velocity based on current position and previous position.
  void _updateDragVelocity(Offset currentOffset) {
    final DateTime currentTime = DateTime.now();
    final Duration timeDiff = currentTime.difference(_previousTime);
    final Offset offsetDiff = currentOffset - _previousOffset;

    // Calculate velocity in pixels per second.
    // Ensure the duration is in milliseconds to compute per-second velocity.
    final double vx = timeDiff.inMilliseconds > 0
        ? (offsetDiff.dx / timeDiff.inMilliseconds) * 1000
        : 0;

    final double vy = timeDiff.inMilliseconds > 0
        ? (offsetDiff.dy / timeDiff.inMilliseconds) * 1000
        : 0;

    _dragVelocity = VelocityEstimate(
      confidence: 1,
      pixelsPerSecond: Offset(vx, vy),
      duration: timeDiff,
      offset: offsetDiff,
    );

    // Update previous values for next calculation
    _previousOffset = currentOffset;
    _previousTime = currentTime;
  }

  /// The duration for animations.
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

  /// Called when a long press starts.
  void onLongPressStart(LongPressStartDetails details) {
    // Initialize position and time tracking
    _previousOffset = details.localPosition;
    _previousTime = DateTime.now();

    onCrosshairAppeared?.call();

    // Stop auto-panning to make it easier to select candle or tick.
    xAxisModel.disableAutoPan();

    final double x = details.localPosition.dx;
    final int epoch = xAxisModel.epochFromX(x);
    final Tick? tick = _findClosestTick(epoch);

    if (tick != null) {
      _showCrosshair(tick, details.localPosition);
    }
  }

  /// Called when a long press is updated.
  void onLongPressUpdate(LongPressMoveUpdateDetails details) {
    // Update drag velocity with the latest gesture data
    _updateDragVelocity(details.localPosition);

    final double x = details.localPosition.dx;
    final int epoch = xAxisModel.epochFromX(x);
    final Tick? tick = _findClosestTick(epoch);

    if (tick != null) {
      _showCrosshair(tick, details.localPosition);
    }

    // Handle auto-panning near the edges
    _updatePanSpeed(x);
  }

  /// Called when a long press ends.
  void onLongPressEnd(LongPressEndDetails details) {
    // Use the velocity provided by the gesture system if available
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

    _hideCrosshair();
  }

  /// Called when the mouse hovers over the chart.
  void onHover(PointerHoverEvent event) {
    final double x = event.localPosition.dx;
    final int epoch = xAxisModel.epochFromX(x);
    final Tick? tick = _findClosestTick(epoch);

    if (tick != null) {
      _showCrosshair(tick, event.localPosition);
    }

    notifyListeners();
  }

  /// Called when the mouse exits the chart.
  void onExit(PointerExitEvent event) {
    _hideCrosshair();
  }

  /// Hides the crosshair.
  void _hideCrosshair() {
    if (value.isVisible) {
      onCrosshairDisappeared?.call();
    }

    value = value.copyWith(
      isVisible: false,
    );

    isCrosshairActive = false;
    notifyListeners(); // Notify listeners when enabled changes
  }

  /// Shows the crosshair with the given tick and position.
  void _showCrosshair(Tick crosshairTick, Offset position) {
    // Only show the crosshair if showCrosshair is true
    if (!showCrosshair) {
      return;
    }

    if (!value.isVisible) {
      onCrosshairAppeared?.call();
    }

    value = value.copyWith(
      crosshairTick: crosshairTick,
      cursorPosition: position,
      isVisible: true,
    );
    isCrosshairActive = true;
    notifyListeners(); // Notify listeners when enabled changes
  }

  /// Finds the closest tick to the given epoch.
  Tick? _findClosestTick(int epoch) {
    return findClosestToEpoch(epoch, series.visibleEntries.entries);
  }

  /// Updates the pan speed based on the cursor position.
  ///
  /// Enables auto-panning when the cursor is near the chart edges (within 60px),
  /// with speed proportional to proximity. This allows users to view data beyond
  /// the current view without manually scrolling.
  void _updatePanSpeed(double x) {
    const double closeDistance = 60;
    const double panSpeed = 0.08;

    if (x < closeDistance) {
      xAxisModel.pan(-panSpeed);
    } else if (xAxisModel.width! - x < closeDistance) {
      xAxisModel.pan(panSpeed);
    } else {
      xAxisModel.pan(0);
    }
  }
}
