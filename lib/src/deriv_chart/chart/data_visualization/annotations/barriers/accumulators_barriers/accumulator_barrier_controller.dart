import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_style.dart';
import 'accumulator_growth_rate_step.dart';

/// Makes the Accumulators band interactive.
///
/// A consumer that wants an interactive band creates one of these, keeps it
/// alive for as long as the chart is mounted, feeds it the ladder of selectable
/// growth rates, and passes it to every [AccumulatorIndicator] it builds. The
/// chart mounts its interaction overlay as soon as it sees an enabled
/// controller on an annotation.
///
/// The band is a tap target, not a control: it highlights on hover and reports
/// [onTap], and the consumer puts its own picker on screen and drives the band
/// from there with [previewGrowthRate].
///
/// The controller owns the transient interaction state (hover, preview) so it
/// survives the annotation being rebuilt on every tick.
class AccumulatorBarrierController extends ChangeNotifier {
  /// Initializes a controller for an interactive Accumulators band.
  AccumulatorBarrierController({
    List<AccumulatorGrowthRateStep> steps = const <AccumulatorGrowthRateStep>[],
    bool enabled = true,
    this.style = const AccumulatorBarrierStyle(),
    bool showTapGuide = false,
    this.onTap,
    this.onPressStart,
  })  : _steps = steps,
        _enabled = enabled,
        _showTapGuide = showTapGuide;

  /// Called when the band is tapped.
  VoidCallback? onTap;

  /// Called the moment a press lands on the band, before it is known whether it
  /// will become a tap or a pan.
  ///
  /// This is how a consumer tells its own gestures apart from the chart's. A
  /// host listening on the document in the capture phase decides what a gesture
  /// means before the chart ever sees it, so being told at [onTap] is too late
  /// — by then a tap-anywhere handler has already acted on it. This fires early
  /// enough to be read on the pointer-up that follows.
  VoidCallback? onPressStart;

  /// Painting and hit-testing style of the band.
  final AccumulatorBarrierStyle style;

  List<AccumulatorGrowthRateStep> _steps;
  bool _enabled;

  bool _isHovered = false;
  AccumulatorGrowthRateStep? _previewStep;
  AccumulatorBarrierGeometry? _geometry;

  /// Barrier distance the current transition started from, and the distance the
  /// painter last actually drew.
  ///
  /// The painter reports back what it drew so a rung change mid-glide can carry
  /// on from where the band visually is, rather than snapping back to the rung
  /// it was heading away from.
  double? _previewTransitionFrom;
  double? _lastRenderedPreviewDistance;

  /// Canvas width excluding the Y-axis labels, published by the overlay.
  double? _graphAreaWidth;

  /// The ladder of growth rates the consumer may preview.
  ///
  /// Order does not matter; a rate is matched to its rung by value.
  List<AccumulatorGrowthRateStep> get steps => _steps;

  set steps(List<AccumulatorGrowthRateStep> value) {
    if (listEquals(_steps, value)) {
      return;
    }
    _steps = value;
    notifyListeners();
  }

  /// Whether the band is interactive right now.
  ///
  /// The consumer owns every business rule behind this (pre-purchase only,
  /// market open, params unlocked, …). When `false` the chart does not mount
  /// its interaction overlay.
  ///
  /// A ladder with fewer than two rungs is never interactive whatever the
  /// consumer says: there is nothing to pick between, and a band that opens a
  /// picker holding a single value is worse than an inert one.
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

  /// The step the band is currently previewing, if any.
  AccumulatorGrowthRateStep? get previewStep => _previewStep;

  /// Whether the band should be drawn in its emphasised state.
  bool get isHighlighted => _isHovered;

  bool _showTapGuide;

  /// Set once a tap has answered the hint. See [retireTapGuide].
  bool _tapRetiredGuide = false;

  /// Whether to show the one-time hint that the band can be tapped.
  ///
  /// Whether the hint ever returns is the consumer's to remember.
  bool get showTapGuide => _showTapGuide;

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

  /// Shows the band at [growthRate] without waiting for the real barriers.
  ///
  /// This is how the consumer keeps the band with its own picker: the band
  /// follows the selection immediately, and the model's own barriers take over
  /// once the proposal for the committed rate arrives. Pass null to hand the
  /// band back to the model at once.
  ///
  /// A rate the ladder does not hold clears the preview.
  void previewGrowthRate(double? growthRate) {
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

    // Glide from wherever the band currently is.
    _previewTransitionFrom =
        _lastRenderedPreviewDistance ?? _geometry?.committedBarrierSpotDistance;
    _previewStep = step;
    notifyListeners();
  }

  /// Drops any preview, handing the band back to the model's own barriers.
  void clearPreview() {
    _previewTransitionFrom = null;
    _lastRenderedPreviewDistance = null;
    if (_previewStep == null) {
      return;
    }
    _previewStep = null;
    notifyListeners();
  }

  /// The geometry of the last painted frame, or `null` before the first paint.
  @internal
  AccumulatorBarrierGeometry? get geometry => _geometry;

  /// Where the plotting area ends. `null` until the overlay is built, in which
  /// case the painter falls back to the full canvas width.
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

  /// Records the barrier distance the painter just drew.
  ///
  /// Called from `paint`, so it must never notify listeners.
  @internal
  // ignore: use_setters_to_change_properties
  void publishRenderedPreviewDistance(double? distance) =>
      _lastRenderedPreviewDistance = distance;

  /// Sets whether the pointer is over the band.
  @internal
  void setHovered({required bool isHovered}) {
    if (_isHovered == isHovered) {
      return;
    }
    _isHovered = isHovered;
    notifyListeners();
  }

  void _resetInteraction() {
    _previewTransitionFrom = null;
    _lastRenderedPreviewDistance = null;
    _previewStep = null;
    _isHovered = false;
  }
}
