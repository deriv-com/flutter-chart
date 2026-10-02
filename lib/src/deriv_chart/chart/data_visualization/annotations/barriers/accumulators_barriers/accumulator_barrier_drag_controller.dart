import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_grip_style.dart';
import 'accumulator_barrier_side.dart';
import 'accumulator_growth_rate_step.dart';

/// Makes the Accumulators barriers interactive.
///
/// A consumer that wants interactive barriers creates one of these, keeps it
/// alive for as long as the chart is mounted, feeds it the ladder of selectable
/// growth rates, and passes it to every [AccumulatorIndicator] it builds. The
/// chart mounts its interaction overlay as soon as it sees an enabled
/// controller on an annotation.
///
/// There are two ways to drive it, and [dragEnabled] picks between them:
///
/// * **Tapping** (the default). The band is a tap target: it highlights on
///   hover and reports [onTap], and the consumer drives the band with
///   [previewGrowthRate] from whatever control it puts on screen.
/// * **Dragging**. The barriers carry grips and the chart snaps the band
///   through the ladder itself, reporting each rung as the user drags.
///
/// The controller owns the transient interaction state (hover, drag, preview)
/// so it survives the annotation being rebuilt on every tick.
class AccumulatorBarrierDragController extends ChangeNotifier {
  /// Initializes a controller for interactive Accumulators barriers.
  AccumulatorBarrierDragController({
    List<AccumulatorGrowthRateStep> steps = const <AccumulatorGrowthRateStep>[],
    bool enabled = true,
    this.dragEnabled = false,
    this.gripStyle = const AccumulatorBarrierGripStyle(),
    this.commitTimeout = const Duration(seconds: 5),
    bool showTapGuide = false,
    this.onTap,
    this.onPressStart,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  })  : _steps = steps,
        _enabled = enabled,
        _showTapGuide = showTapGuide;

  /// Whether the user can drag the barriers through the ladder.
  ///
  /// When false — the default — the band is a tap target instead: no grips are
  /// drawn, no drag is recognised, and the consumer moves the band itself with
  /// [previewGrowthRate]. [onDragStart], [onDragUpdate] and [onDragEnd] never
  /// fire.
  final bool dragEnabled;

  /// Called when the band is tapped. Only fires while [dragEnabled] is false.
  VoidCallback? onTap;

  /// Called the moment a press lands on the band, before it is known whether it
  /// will become a tap or a pan. Only fires while [dragEnabled] is false.
  ///
  /// This is how a consumer tells its own gestures apart from the chart's. A
  /// host listening on the document in the capture phase decides what a gesture
  /// means before the chart ever sees it, so being told at [onTap] is too late
  /// — by then a tap-anywhere handler has already acted on it. This fires early
  /// enough to be read on the pointer-up that follows.
  VoidCallback? onPressStart;

  /// Painting and hit-testing style of the grips.
  final AccumulatorBarrierGripStyle gripStyle;

  /// How long the committed preview is held after a drag ends while waiting
  /// for the consumer to push the matching barriers back down.
  ///
  /// When it elapses the preview is dropped and the model's own barriers are
  /// shown again.
  final Duration commitTimeout;

  /// Called once when a drag begins, with the grip that was grabbed.
  void Function(AccumulatorBarrierSide side)? onDragStart;

  /// Called every time the drag snaps to a different step.
  void Function(AccumulatorGrowthRateStep step, AccumulatorBarrierSide side)?
      onDragUpdate;

  /// Called once when the drag ends, with the step the user settled on.
  ///
  /// The side is reported alongside because which grip is in hand decides
  /// which way the user has to drag to leave a ladder's end — at the tightest
  /// band the top grip goes up and the bottom one goes down.
  void Function(AccumulatorGrowthRateStep step, AccumulatorBarrierSide side)?
      onDragEnd;

  List<AccumulatorGrowthRateStep> _steps;
  bool _enabled;

  /// Ladder handed over while a drag was in progress, applied once it ends.
  List<AccumulatorGrowthRateStep>? _pendingSteps;

  AccumulatorBarrierSide? _hoveredSide;
  AccumulatorBarrierSide? _draggedSide;
  AccumulatorGrowthRateStep? _previewStep;
  AccumulatorBarrierGeometry? _geometry;

  /// Committed half-width recorded when the last drag ended. While non-null the
  /// preview is *latched*: it keeps rendering until the model moves away from
  /// this value (the consumer's commit landed) or [commitTimeout] elapses.
  double? _latchedCommittedDistance;
  Timer? _commitTimer;

  /// Barrier distance the current transition started from, and the distance the
  /// painter last actually drew.
  ///
  /// The painter reports back what it drew so a rung change mid-glide can carry
  /// on from where the band visually is, rather than snapping back to the rung
  /// it was heading away from.
  double? _previewTransitionFrom;
  double? _lastRenderedPreviewDistance;

  /// Canvas width excluding the Y-axis labels, published by the drag overlay.
  double? _graphAreaWidth;

  /// The ladder of growth rates the drag snaps to.
  ///
  /// Order does not matter; the nearest step by barrier distance always wins.
  List<AccumulatorGrowthRateStep> get steps => _steps;

  /// Updates to the ladder are held back for the duration of a drag.
  ///
  /// Barrier distances move with the spot, so a ladder that refreshed on every
  /// tick would shift the snap targets under the user's finger — and the rungs
  /// sit close enough together that a rung could change without the pointer
  /// moving at all. The newest ladder is applied as soon as the drag ends.
  set steps(List<AccumulatorGrowthRateStep> value) {
    if (isDragging) {
      _pendingSteps = value;
      return;
    }
    _applySteps(value);
  }

  void _applySteps(List<AccumulatorGrowthRateStep> value) {
    if (listEquals(_steps, value)) {
      return;
    }
    _steps = value;
    notifyListeners();
  }

  /// Distance in quote units between the tightest and widest rung, or 0 when
  /// there is nothing to span. Used to scale the drag.
  double get ladderSpan {
    if (_steps.length < 2) {
      return 0;
    }

    double min = _steps.first.barrierSpotDistance;
    double max = min;

    for (final AccumulatorGrowthRateStep step in _steps.skip(1)) {
      if (step.barrierSpotDistance < min) {
        min = step.barrierSpotDistance;
      }
      if (step.barrierSpotDistance > max) {
        max = step.barrierSpotDistance;
      }
    }

    return max - min;
  }

  /// Whether the barriers can currently be dragged.
  ///
  /// The consumer owns every business rule behind this (pre-purchase only,
  /// market open, params unlocked, …). When `false` no grips are drawn and the
  /// chart does not mount its drag overlay.
  ///
  /// A ladder with fewer than two rungs is never draggable whatever the
  /// consumer says: there is nowhere to drag to, and grips the user cannot move
  /// are worse than none.
  bool get enabled => _enabled && _steps.length > 1;

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

  bool _showTapGuide;

  /// Set once a tap has answered the hint. See [retireTapGuide].
  bool _tapRetiredGuide = false;

  /// Whether to show the one-time hint that the band can be tapped.
  ///
  /// Never true while [dragEnabled]: the hint says "tap", and a consumer that
  /// has turned dragging back on has grips instead of a tap target. Whether
  /// the hint ever returns is the consumer's to remember.
  bool get showTapGuide => _showTapGuide && !dragEnabled;

  set showTapGuide(bool value) {
    // A consumer goes on sending the old value for the frame or two before its
    // own state catches up with the tap, and the band republishes on every
    // tick, so without the latch the hint flicks back on over the control the
    // tap just opened. Sending false clears it, which is also how a consumer
    // that wants the hint back later asks for it.
    if (value && _tapRetiredGuide) {
      return;
    }
    if (!value) {
      _tapRetiredGuide = false;
    }
    if (_showTapGuide == value) {
      return;
    }
    _showTapGuide = value;
    notifyListeners();
  }

  /// Drops the hint because the band was tapped, which is what it was asking
  /// for, rather than waiting for the consumer's flag to come back.
  void retireTapGuide() {
    _tapRetiredGuide = true;
    if (!_showTapGuide) {
      return;
    }
    _showTapGuide = false;
    notifyListeners();
  }

  /// Barrier distance the band is gliding away from, or `null` when there is
  /// nothing to glide from and the preview should be drawn outright.
  double? get previewTransitionFrom => _previewTransitionFrom;

  /// Barrier distance the painter last drew for the preview, so the chart can
  /// glide on from the band the user was actually looking at once the real
  /// barriers replace it.
  @internal
  double? get renderedPreviewDistance => _lastRenderedPreviewDistance;

  /// The step nearest to the currently committed band, or `null` when the
  /// ladder is empty or the barriers have not been painted yet.
  AccumulatorGrowthRateStep? get committedStep {
    final AccumulatorBarrierGeometry? geometry = _geometry;
    if (geometry == null) {
      return null;
    }
    return nearestStep(geometry.committedBarrierSpotDistance);
  }

  /// Shows the band at [growthRate] without waiting for the real barriers.
  ///
  /// This is how a consumer that owns the control — a picker of its own rather
  /// than the chart's grips — keeps the band with it: the band follows the
  /// selection immediately, and the model's own barriers take over once the
  /// proposal for the committed rate arrives. Pass null to hand the band back
  /// to the model at once.
  ///
  /// Ignored while a drag is in flight, so a late consumer update cannot fight
  /// the user's finger. A rate the ladder does not hold clears the preview.
  void previewGrowthRate(double? growthRate) {
    if (isDragging) {
      return;
    }

    if (growthRate == null) {
      clearPreview();
      return;
    }

    final AccumulatorGrowthRateStep? step = _steps.firstWhereOrNull(
        (AccumulatorGrowthRateStep s) => s.growthRate == growthRate);

    if (step == null) {
      clearPreview();
      return;
    }
    if (_previewStep == step) {
      return;
    }

    // Glide from wherever the band currently is, the same way a drag does.
    _previewTransitionFrom =
        _lastRenderedPreviewDistance ?? _geometry?.committedBarrierSpotDistance;
    _previewStep = step;
    notifyListeners();
  }

  /// Drops any preview and stops waiting for a commit.
  ///
  /// Consumers call this when the commit they were asked for is not going to
  /// happen (rejected proposal, trade type switched away, …).
  void clearPreview() {
    _commitTimer?.cancel();
    _commitTimer = null;
    _latchedCommittedDistance = null;
    _previewTransitionFrom = null;
    _lastRenderedPreviewDistance = null;
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

  /// Where the plotting area ends, so the grips can sit against the Y axis
  /// rather than in the middle of the band. `null` until the overlay is built,
  /// in which case the painter falls back to the full canvas width.
  @internal
  double? get graphAreaWidth => _graphAreaWidth;

  /// Published by the overlay, which is the only part of this that the chart
  /// hands a width to. Never notifies — it is read during the same frame's
  /// paint.
  @internal
  // ignore: use_setters_to_change_properties
  void publishGraphAreaWidth(double? width) => _graphAreaWidth = width;

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
    onDragStart?.call(side);
  }

  /// Moves the preview to [step], if it differs from the current one.
  @internal
  void updateDrag(AccumulatorGrowthRateStep? step) {
    final AccumulatorBarrierSide? side = _draggedSide;
    if (step == null || side == null || _previewStep == step) {
      return;
    }
    // Glide from wherever the band currently is: the last painted distance
    // mid-transition, the previous rung once it has settled, or the committed
    // band on the first move of a drag.
    _previewTransitionFrom = _lastRenderedPreviewDistance ??
        _previewStep?.barrierSpotDistance ??
        _geometry?.committedBarrierSpotDistance;
    _previewStep = step;
    notifyListeners();
    onDragUpdate?.call(step, side);
  }

  /// Records the barrier distance the painter just drew.
  ///
  /// Called from `paint`, so it must never notify listeners.
  @internal
  // ignore: use_setters_to_change_properties
  void publishRenderedPreviewDistance(double? distance) =>
      _lastRenderedPreviewDistance = distance;

  /// Ends the drag.
  ///
  /// [onDragEnd] fires on every release, so a consumer that put something on
  /// screen at [onDragStart] always hears the gesture finish. When [commit] is
  /// true and a step was previewed it reports that step and latches the preview
  /// until the model catches up; otherwise it reports the rung the band is
  /// already on, which is what a release that previewed nothing settled on.
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
      // A tap that never moved the band, or a cancelled gesture. Nothing was
      // chosen, so there is nothing to latch or time out — but the consumer
      // still has to hear the release, or whatever it showed on drag start is
      // left on screen with nothing to take it down.
      _previewStep = null;
      _flushPendingSteps();
      notifyListeners();

      final AccumulatorGrowthRateStep? current = committedStep;
      if (current != null) {
        onDragEnd?.call(current, side);
      }
      return;
    }

    _latchedCommittedDistance = _geometry?.committedBarrierSpotDistance;
    _commitTimer = Timer(commitTimeout, clearPreview);
    _flushPendingSteps();
    notifyListeners();
    onDragEnd?.call(settled, side);
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

  /// Applies a ladder that arrived mid-drag. Assigns directly rather than going
  /// through [_applySteps], because the caller notifies once for the whole
  /// drag-end transition.
  void _flushPendingSteps() {
    final List<AccumulatorGrowthRateStep>? pending = _pendingSteps;
    _pendingSteps = null;
    if (pending != null && !listEquals(_steps, pending)) {
      _steps = pending;
    }
  }

  void _resetInteraction() {
    _commitTimer?.cancel();
    _commitTimer = null;
    _flushPendingSteps();
    _latchedCommittedDistance = null;
    _previewTransitionFrom = null;
    _lastRenderedPreviewDistance = null;
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
