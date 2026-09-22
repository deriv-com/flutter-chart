import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_grip_style.dart';
import 'accumulator_barrier_side.dart';
import 'accumulator_growth_rate_step.dart';

/// Makes the Accumulators barriers draggable.
///
/// A consumer that wants draggable barriers creates one of these, keeps it
/// alive for as long as the chart is mounted, feeds it the ladder of selectable
/// growth rates, and passes it to every [AccumulatorIndicator] it builds. The
/// chart mounts its drag overlay as soon as it sees an enabled controller on an
/// annotation.
///
/// The controller owns the transient interaction state (hover, drag, preview)
/// so it survives the annotation being rebuilt on every tick.
class AccumulatorBarrierDragController extends ChangeNotifier {
  /// Initializes a controller for draggable Accumulators barriers.
  AccumulatorBarrierDragController({
    List<AccumulatorGrowthRateStep> steps = const <AccumulatorGrowthRateStep>[],
    bool enabled = true,
    this.gripStyle = const AccumulatorBarrierGripStyle(),
    this.commitTimeout = const Duration(seconds: 5),
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  })  : _steps = steps,
        _enabled = enabled;

  /// Painting and hit-testing style of the grips.
  final AccumulatorBarrierGripStyle gripStyle;

  /// How long the committed preview is held after a drag ends while waiting
  /// for the consumer to push the matching barriers back down.
  ///
  /// When it elapses the preview is dropped and the model's own barriers are
  /// shown again.
  final Duration commitTimeout;

  /// Called once when a drag begins.
  VoidCallback? onDragStart;

  /// Called every time the drag snaps to a different step.
  void Function(AccumulatorGrowthRateStep step)? onDragUpdate;

  /// Called once when the drag ends, with the step the user settled on.
  void Function(AccumulatorGrowthRateStep step)? onDragEnd;

  List<AccumulatorGrowthRateStep> _steps;
  bool _enabled;

  AccumulatorBarrierSide? _hoveredSide;
  AccumulatorBarrierSide? _draggedSide;
  AccumulatorGrowthRateStep? _previewStep;
  AccumulatorBarrierGeometry? _geometry;

  /// Committed half-width recorded when the last drag ended. While non-null the
  /// preview is *latched*: it keeps rendering until the model moves away from
  /// this value (the consumer's commit landed) or [commitTimeout] elapses.
  double? _latchedCommittedDistance;
  Timer? _commitTimer;

  /// The ladder of growth rates the drag snaps to.
  ///
  /// Order does not matter; the nearest step by barrier distance always wins.
  List<AccumulatorGrowthRateStep> get steps => _steps;

  set steps(List<AccumulatorGrowthRateStep> value) {
    if (listEquals(_steps, value)) {
      return;
    }
    _steps = value;
    notifyListeners();
  }

  /// Whether the barriers can currently be dragged.
  ///
  /// The consumer owns every business rule behind this (pre-purchase only,
  /// market open, params unlocked, …). When `false` no grips are drawn and the
  /// chart does not mount its drag overlay.
  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    if (!value) {
      _resetInteraction();
    }
    notifyListeners();
  }

  /// Whether a drag is in progress.
  bool get isDragging => _draggedSide != null;

  /// The barrier the pointer is hovering, if any.
  AccumulatorBarrierSide? get hoveredSide => _hoveredSide;

  /// The barrier being dragged, if any.
  AccumulatorBarrierSide? get draggedSide => _draggedSide;

  /// The step the barriers are currently previewing.
  ///
  /// Non-null while dragging, and for a short while afterwards so the band does
  /// not snap back before the consumer's committed barriers arrive.
  AccumulatorGrowthRateStep? get previewStep => _previewStep;

  /// Whether the barriers should be drawn in their emphasised state.
  bool get isHighlighted => _hoveredSide != null || isDragging;

  /// The step nearest to the currently committed band, or `null` when the
  /// ladder is empty or the barriers have not been painted yet.
  AccumulatorGrowthRateStep? get committedStep {
    final AccumulatorBarrierGeometry? geometry = _geometry;
    if (geometry == null) {
      return null;
    }
    return nearestStep(geometry.committedBarrierSpotDistance);
  }

  /// Drops any preview and stops waiting for a commit.
  ///
  /// Consumers call this when the commit they were asked for is not going to
  /// happen (rejected proposal, trade type switched away, …).
  void clearPreview() {
    _commitTimer?.cancel();
    _commitTimer = null;
    _latchedCommittedDistance = null;
    if (_previewStep == null) {
      return;
    }
    _previewStep = null;
    notifyListeners();
  }

  /// Returns the step whose barrier distance is closest to [distance].
  ///
  /// [hysteresis] biases the result towards [previewStep] so the preview does
  /// not chatter when the pointer sits on a boundary between two steps.
  AccumulatorGrowthRateStep? nearestStep(
    double distance, {
    double hysteresis = 0,
  }) {
    if (_steps.isEmpty) {
      return null;
    }

    AccumulatorGrowthRateStep best = _steps.first;
    double bestDelta = (best.barrierSpotDistance - distance).abs();

    for (final AccumulatorGrowthRateStep step in _steps.skip(1)) {
      final double delta = (step.barrierSpotDistance - distance).abs();
      if (delta < bestDelta) {
        best = step;
        bestDelta = delta;
      }
    }

    final AccumulatorGrowthRateStep? current = _previewStep;
    if (hysteresis > 0 && current != null && _steps.contains(current)) {
      final double currentDelta =
          (current.barrierSpotDistance - distance).abs();
      if (currentDelta <= bestDelta + hysteresis) {
        return current;
      }
    }

    return best;
  }

  /// The geometry of the last painted frame, or `null` before the first paint.
  @internal
  AccumulatorBarrierGeometry? get geometry => _geometry;

  /// Records the geometry the painter just resolved.
  ///
  /// Called from `paint`, so it must never notify listeners — which is exactly
  /// why this is a method and not a setter paired with [geometry].
  @internal
  // ignore: use_setters_to_change_properties
  void publishGeometry(AccumulatorBarrierGeometry value) => _geometry = value;

  /// Sets (or clears) the hovered barrier.
  @internal
  void setHovered(AccumulatorBarrierSide? side) {
    if (_hoveredSide == side) {
      return;
    }
    _hoveredSide = side;
    notifyListeners();
  }

  /// Starts a drag on [side].
  @internal
  void beginDrag(AccumulatorBarrierSide side) {
    _commitTimer?.cancel();
    _commitTimer = null;
    _latchedCommittedDistance = null;
    _draggedSide = side;
    _hoveredSide = side;
    notifyListeners();
    onDragStart?.call();
  }

  /// Moves the preview to [step], if it differs from the current one.
  @internal
  void updateDrag(AccumulatorGrowthRateStep? step) {
    if (step == null || _previewStep == step) {
      return;
    }
    _previewStep = step;
    notifyListeners();
    onDragUpdate?.call(step);
  }

  /// Ends the drag.
  ///
  /// When [commit] is true the preview is latched until the model catches up,
  /// and [onDragEnd] fires with the settled step.
  @internal
  void endDrag({required bool commit}) {
    final AccumulatorBarrierSide? side = _draggedSide;
    if (side == null) {
      return;
    }
    _draggedSide = null;
    _hoveredSide = null;

    final AccumulatorGrowthRateStep? settled = _previewStep;
    if (!commit || settled == null) {
      _previewStep = null;
      notifyListeners();
      return;
    }

    _latchedCommittedDistance = _geometry?.committedBarrierSpotDistance;
    _commitTimer = Timer(commitTimeout, clearPreview);
    notifyListeners();
    onDragEnd?.call(settled);
  }

  /// Releases a latched preview once the model has moved in response to the
  /// commit. Returns true when the latch was released by this call.
  ///
  /// The incoming barriers are compared against what was committed at drag end
  /// rather than against the previewed step, because the consumer's ladder may
  /// only approximate the real barrier distances.
  @internal
  bool releaseLatchIfModelMoved({
    required double highBarrier,
    required double lowBarrier,
  }) {
    final double? latched = _latchedCommittedDistance;
    if (latched == null || _previewStep == null || isDragging) {
      return false;
    }

    final double incoming = (highBarrier - lowBarrier).abs() / 2;
    if ((incoming - latched).abs() <= _distanceEpsilon) {
      return false;
    }

    clearPreview();
    return true;
  }

  void _resetInteraction() {
    _commitTimer?.cancel();
    _commitTimer = null;
    _latchedCommittedDistance = null;
    _previewStep = null;
    _hoveredSide = null;
    _draggedSide = null;
  }

  @override
  void dispose() {
    _commitTimer?.cancel();
    _commitTimer = null;
    super.dispose();
  }

  /// Quote-space slack below which two barrier distances count as unchanged.
  static const double _distanceEpsilon = 1e-9;
}
