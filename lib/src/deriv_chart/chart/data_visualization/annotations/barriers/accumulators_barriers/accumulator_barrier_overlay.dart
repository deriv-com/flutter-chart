import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'accumulator_barrier_controller.dart';
import 'accumulator_barrier_geometry.dart';
import 'accumulator_barrier_gesture_recognizer.dart';
import 'accumulator_growth_rate_step.dart';

/// Transparent layer that turns the Accumulators band into a tap target.
///
/// It captures hover and taps over the band and writes the resulting
/// interaction state onto the controller. It never paints anything —
/// `AccumulatorIndicatorPainter` renders both the idle and the previewed band,
/// so there is exactly one source of truth for the pixels.
class AccumulatorBarrierOverlay extends StatefulWidget {
  /// Initializes the interaction layer for the Accumulators band.
  const AccumulatorBarrierOverlay({
    required this.controller,
    required this.onInteractionChanged,
    this.graphAreaWidth,
    super.key,
  });

  /// The controller the chart found on the accumulators annotation.
  final AccumulatorBarrierController controller;

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
  /// crosses the band.
  final VoidCallback onInteractionChanged;

  @override
  State<AccumulatorBarrierOverlay> createState() =>
      _AccumulatorBarrierOverlayState();
}

class _AccumulatorBarrierOverlayState extends State<AccumulatorBarrierOverlay> {
  late final AccumulatorBarrierGestureRecognizer _recognizer =
      AccumulatorBarrierGestureRecognizer(
    bandHitTest: _onBand,
    onBandTap: _handleTap,
    onBandPress: _handlePress,
    debugOwner: this,
  );

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
  void didUpdateWidget(covariant AccumulatorBarrierOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _lastReportedPreview = widget.controller.previewStep;
    }
  }

  /// Splits a controller change into the cheap part and the expensive one.
  ///
  /// Hover changes what this widget renders — the cursor — so it always
  /// rebuilds itself, which costs a `MouseRegion` and a `SizedBox`. Only a
  /// change of previewed step moves the band, and only that needs the chart to
  /// re-measure its quote bounds.
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
    _recognizer.dispose();
    super.dispose();
  }

  /// The geometry to hit-test against, or null when the band is not interactive
  /// or the pointer is over the quote labels.
  AccumulatorBarrierGeometry? _hittableGeometry(Offset local) {
    final AccumulatorBarrierGeometry? geometry = widget.controller.geometry;
    if (geometry == null || !widget.controller.enabled) {
      return null;
    }

    final double? graphAreaWidth = widget.graphAreaWidth;
    if (graphAreaWidth != null && local.dx > graphAreaWidth) {
      return null;
    }

    return geometry;
  }

  bool _isPrecise(PointerDeviceKind kind) =>
      kind == PointerDeviceKind.mouse ||
      kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.trackpad;

  double _tolerance(PointerDeviceKind kind) => _isPrecise(kind)
      ? widget.controller.style.mouseHitTolerance
      : widget.controller.style.touchHitTolerance;

  /// Whether [local] falls on the band, which is the tap target.
  bool _onBand(Offset local, PointerDeviceKind kind) =>
      _hittableGeometry(local)
          ?.containsBand(local, tolerance: _tolerance(kind)) ??
      false;

  void _handleHover(PointerHoverEvent event) {
    widget.controller
        .setHovered(isHovered: _onBand(event.localPosition, event.kind));
  }

  void _handleExit(PointerExitEvent event) =>
      widget.controller.setHovered(isHovered: false);

  void _handleTap() {
    // Dropped here, on the tap it was asking for, rather than waiting for the
    // consumer's flag to come back a round-trip later — by which time the hint
    // would be sitting over the control it just opened.
    widget.controller.retireTapGuide();
    widget.controller.onTap?.call();
  }

  void _handlePress() => widget.controller.onPressStart?.call();

  @override
  Widget build(BuildContext context) {
    // The painter reads this to know where the plotting area ends, and this is
    // the only place the chart hands it over. Safe to do here: every build of
    // this widget precedes the frame's paint.
    widget.controller.publishGraphAreaWidth(widget.graphAreaWidth);

    _recognizer.updateCallbacks(
      bandHitTest: _onBand,
      onBandTap: _handleTap,
      onBandPress: _handlePress,
    );

    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: widget.controller.isHighlighted
          ? widget.controller.style.cursor
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
