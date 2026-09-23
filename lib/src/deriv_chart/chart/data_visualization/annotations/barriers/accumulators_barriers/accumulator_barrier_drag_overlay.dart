import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'accumulator_barrier_drag_controller.dart';
import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_gesture_recognizer.dart';
import 'accumulator_barrier_grip_style.dart';
import 'accumulator_barrier_side.dart';
import 'accumulator_growth_rate_step.dart';

/// Transparent layer that turns the Accumulators barriers into a control.
///
/// It captures hover and drag over the barrier lines and their grips, and
/// writes the resulting interaction state onto the controller. It never paints
/// anything — `AccumulatorIndicatorPainter` renders both the idle and the
/// previewed band, so there is exactly one source of truth for the pixels.
class AccumulatorBarrierDragOverlay extends StatefulWidget {
  /// Initializes the drag layer for the Accumulators barriers.
  const AccumulatorBarrierDragOverlay({
    required this.controller,
    required this.quoteFromCanvasY,
    required this.onInteractionChanged,
    this.graphAreaWidth,
    this.onDragBegin,
    this.onDragFinish,
    super.key,
  });

  /// The controller the chart found on the accumulators annotation.
  final AccumulatorBarrierDragController controller;

  /// Converts a canvas Y coordinate back into a quote.
  final QuoteFromY quoteFromCanvasY;

  /// Width of the plotting area, i.e. everything left of the quote labels.
  ///
  /// The barrier lines are painted all the way to the canvas edge, but the
  /// strip under the labels belongs to the Y-axis scale gesture — claiming a
  /// pointer there would take vertical scaling away from the user.
  final double? graphAreaWidth;

  /// Called when the previewed band moves, so the chart can recompute the quote
  /// bounds it has to fit.
  ///
  /// Deliberately not called for hover: that only restyles the barriers, which
  /// the annotation layer repaints on its own, and this callback is expensive
  /// enough to show up on a CPU profile if it runs every time the pointer
  /// crosses a barrier.
  final VoidCallback onInteractionChanged;

  /// Called when a drag starts, so the chart can suspend competing behaviour.
  final VoidCallback? onDragBegin;

  /// Called when a drag ends or is cancelled.
  final VoidCallback? onDragFinish;

  @override
  State<AccumulatorBarrierDragOverlay> createState() =>
      _AccumulatorBarrierDragOverlayState();
}

class _AccumulatorBarrierDragOverlayState
    extends State<AccumulatorBarrierDragOverlay> {
  late final AccumulatorBarrierGestureRecognizer _recognizer =
      AccumulatorBarrierGestureRecognizer(
    hitTest: _hitTest,
    onBarrierDragStart: _handleDragStart,
    onBarrierDragUpdate: _handleDragUpdate,
    onBarrierDragEnd: _handleDragEnd,
    onBarrierDragCancel: _handleDragCancel,
    debugOwner: this,
  );

  /// Quote at the vertical centre of the band, captured once per drag so the
  /// mapping from pointer position to barrier distance cannot drift while the
  /// user's finger is down.
  double? _dragCenterQuote;

  /// Barrier distance the band was committed to when the drag began, and the
  /// factor pointer travel is divided by. Both are fixed for the whole gesture
  /// so the mapping cannot shift under the user's finger.
  double? _dragStartDistance;
  double _dragGain = 1;

  /// How far the pointer must travel, in logical pixels, before the preview is
  /// allowed to switch away from the current step.
  static const double _hysteresisInPixels = 2;

  /// Preview the chart was last told about, so hover-only notifications can be
  /// told apart from ones that actually move the band.
  AccumulatorGrowthRateStep? _lastReportedPreview;

  @override
  void initState() {
    super.initState();
    _lastReportedPreview = widget.controller.previewStep;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AccumulatorBarrierDragOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _lastReportedPreview = widget.controller.previewStep;
    }
  }

  /// Splits a controller change into the cheap part and the expensive one.
  ///
  /// Hover and drag state both change what this widget renders — the cursor —
  /// so it always rebuilds itself, which costs a `MouseRegion` and a
  /// `SizedBox`. Only a change of previewed step moves the band, and only that
  /// needs the chart to re-measure its quote bounds.
  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final AccumulatorGrowthRateStep? preview = widget.controller.previewStep;
    final bool previewChanged = preview != _lastReportedPreview;
    _lastReportedPreview = preview;

    setState(() {});

    if (previewChanged) {
      widget.onInteractionChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    if (widget.controller.isDragging) {
      widget.controller.endDrag(commit: false);
      widget.onDragFinish?.call();
    }
    _recognizer.dispose();
    super.dispose();
  }

  AccumulatorBarrierSide? _hitTest(Offset local, PointerDeviceKind kind) {
    final AccumulatorBarrierGeometry? geometry = widget.controller.geometry;
    if (geometry == null || !widget.controller.enabled) {
      return null;
    }

    final double? graphAreaWidth = widget.graphAreaWidth;
    if (graphAreaWidth != null && local.dx > graphAreaWidth) {
      return null;
    }

    final bool isPrecise = kind == PointerDeviceKind.mouse ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.trackpad;

    return geometry.hitTest(
      local,
      lineTolerance: isPrecise
          ? widget.controller.gripStyle.mouseHitTolerance
          : widget.controller.gripStyle.touchHitTolerance,
      minTouchTarget:
          isPrecise ? Size.zero : widget.controller.gripStyle.minTouchTarget,
    );
  }

  void _handleHover(PointerHoverEvent event) =>
      widget.controller.setHovered(_hitTest(event.localPosition, event.kind));

  void _handleExit(PointerExitEvent event) {
    if (!widget.controller.isDragging) {
      widget.controller.setHovered(null);
    }
  }

  void _handleDragStart(AccumulatorBarrierSide side, Offset local) {
    final AccumulatorBarrierGeometry? geometry = widget.controller.geometry;
    _dragCenterQuote = geometry?.bandCenterQuote;
    // Anchor on what the band is actually showing, which is the latched preview
    // when a previous commit is still in flight — anchoring on the committed
    // distance instead would make the band jump on touch-down.
    _dragStartDistance = widget.controller.previewStep?.barrierSpotDistance ??
        geometry?.committedBarrierSpotDistance;
    _dragGain = _resolveDragGain();
    widget.controller.beginDrag(side);
    widget.onDragBegin?.call();
  }

  /// How much pointer travel to trade for a unit of barrier movement.
  ///
  /// Barrier distances across the ladder can be only a handful of pixels apart,
  /// which would put every growth rate within a flick of each other. Scaling the
  /// drag so the whole ladder takes [AccumulatorBarrierGripStyle.ladderTravel]
  /// pixels keeps the gesture usable; a ladder already wider than that is left
  /// alone, since reducing sensitivity would only make it worse.
  double _resolveDragGain() {
    final AccumulatorBarrierGripStyle style = widget.controller.gripStyle;
    final double quotesPerPixel = _quotesPerPixel();
    final double ladderSpan = widget.controller.ladderSpan;

    if (quotesPerPixel <= 0 || ladderSpan <= 0) {
      return 1;
    }

    final double ladderSpanInPixels = ladderSpan / quotesPerPixel;
    if (ladderSpanInPixels >= style.ladderTravel) {
      return 1;
    }

    return (style.ladderTravel / ladderSpanInPixels)
        .clamp(1, style.maxDragGain);
  }

  void _handleDragUpdate(Offset local) {
    final double? centerQuote = _dragCenterQuote;
    if (centerQuote == null) {
      return;
    }

    final double pointerQuote = widget.quoteFromCanvasY(local.dy);
    final double pointerDistance =
        widget.controller.draggedSide == AccumulatorBarrierSide.high
            ? pointerQuote - centerQuote
            : centerQuote - pointerQuote;

    // Scale the pointer's travel down onto the ladder, around wherever the band
    // was when the drag started.
    final double startDistance = _dragStartDistance ?? pointerDistance;
    final double distance =
        startDistance + (pointerDistance - startDistance) / _dragGain;

    widget.controller.updateDrag(
      widget.controller.nearestStep(
        distance < 0 ? 0 : distance,
        // Expressed in pointer pixels, so the slack feels the same whatever
        // the gain works out to be.
        hysteresis: _quotesPerPixel() * _hysteresisInPixels / _dragGain,
      ),
    );
  }

  void _handleDragEnd() {
    _dragCenterQuote = null;
    _dragStartDistance = null;
    widget.controller.endDrag(commit: true);
    widget.onDragFinish?.call();
  }

  void _handleDragCancel() {
    _dragCenterQuote = null;
    _dragStartDistance = null;
    widget.controller.endDrag(commit: false);
    widget.onDragFinish?.call();
  }

  double _quotesPerPixel() =>
      (widget.quoteFromCanvasY(0) - widget.quoteFromCanvasY(1)).abs();

  @override
  Widget build(BuildContext context) {
    _recognizer.updateCallbacks(
      hitTest: _hitTest,
      onBarrierDragStart: _handleDragStart,
      onBarrierDragUpdate: _handleDragUpdate,
      onBarrierDragEnd: _handleDragEnd,
      onBarrierDragCancel: _handleDragCancel,
    );

    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: widget.controller.hoveredSide != null
          ? widget.controller.gripStyle.cursor
          : MouseCursor.defer,
      onHover: _handleHover,
      onExit: _handleExit,
      child: RawGestureDetector(
        // Must stay translucent: `RenderStack` stops hit-testing at the first
        // child that reports a hit, and the interactive layer below this one
        // is opaque.
        behavior: HitTestBehavior.translucent,
        gestures: <Type, GestureRecognizerFactory<GestureRecognizer>>{
          AccumulatorBarrierGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  AccumulatorBarrierGestureRecognizer>(
            () => _recognizer,
            (AccumulatorBarrierGestureRecognizer instance) {},
          ),
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}
