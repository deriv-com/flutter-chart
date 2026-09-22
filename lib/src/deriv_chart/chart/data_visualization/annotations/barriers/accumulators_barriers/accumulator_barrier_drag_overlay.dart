import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'accumulator_barrier_drag_controller.dart';
import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_gesture_recognizer.dart';
import 'accumulator_barrier_side.dart';

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

  /// Called whenever the interaction state changes and the chart must repaint.
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

  /// How far apart two steps must be, in quote units, before the preview is
  /// allowed to switch away from the current one.
  static const double _hysteresisInPixels = 2;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(widget.onInteractionChanged);
  }

  @override
  void didUpdateWidget(covariant AccumulatorBarrierDragOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.onInteractionChanged != widget.onInteractionChanged) {
      oldWidget.controller.removeListener(oldWidget.onInteractionChanged);
      widget.controller.addListener(widget.onInteractionChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(widget.onInteractionChanged);
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
    _dragCenterQuote = widget.controller.geometry?.bandCenterQuote;
    widget.controller.beginDrag(side);
    widget.onDragBegin?.call();
  }

  void _handleDragUpdate(Offset local) {
    final double? centerQuote = _dragCenterQuote;
    if (centerQuote == null) {
      return;
    }

    final double pointerQuote = widget.quoteFromCanvasY(local.dy);
    final double signedDistance =
        widget.controller.draggedSide == AccumulatorBarrierSide.high
            ? pointerQuote - centerQuote
            : centerQuote - pointerQuote;

    widget.controller.updateDrag(
      widget.controller.nearestStep(
        signedDistance < 0 ? 0 : signedDistance,
        hysteresis: _quotesPerPixel() * _hysteresisInPixels,
      ),
    );
  }

  void _handleDragEnd() {
    _dragCenterQuote = null;
    widget.controller.endDrag(commit: true);
    widget.onDragFinish?.call();
  }

  void _handleDragCancel() {
    _dragCenterQuote = null;
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
