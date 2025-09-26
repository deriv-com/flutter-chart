import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/trend_line/trend_line_adding_preview.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';

/// Animation states for desktop trend line preview
enum DesktopAnimationState {
  /// No animation is currently running
  idle,

  /// Alignment guides are fading out (250ms)
  guideFadeOut,

  /// Delay phase between fade-out and fade-in (100ms)
  guideDelay,

  /// Alignment guides are fading in with simultaneous pulse animation (250ms + 500ms pulse)
  guideFadeIn,

  /// Legacy state - no longer used (pulse runs during guideFadeIn)
  startPointPulse,
}

/// Configuration constants for desktop trend line animations
class _AnimationConfig {
  static const int guideFadeOutDurationMs = 250;
  static const int guideFadeInDurationMs = 250;
  static const int guideDelayDurationMs = 100;
  static const int pulseDurationMs = 500;

  static const double baseRadius = 4;
  static const double maxGlowRadius = 12;
}

/// Manages animation state and values for desktop trend line preview using Flutter's AnimationController
class _DesktopAnimationController {
  AnimationController? _controller;
  late Animation<double> _guideOpacityAnimation;
  late Animation<double> _pulseIntensityAnimation;

  bool _isActive = false;

  /// Whether animation is currently active
  bool get isActive => _isActive;

  /// Current opacity for alignment guides
  double get guideOpacity => _guideOpacityAnimation.value;

  /// Current pulse intensity for start point glow
  double get pulseIntensity => _pulseIntensityAnimation.value;

  /// Initializes the animation controller with the provided ticker and update callback
  void init(AnimationController controller, VoidCallback onUpdate) {
    _controller = controller;

    // Create guide opacity animation sequence:
    // 0-250ms: fade out (1.0 -> 0.0)
    // 250-350ms: delay (stay at 0.0)
    // 350-600ms: fade in (0.0 -> 1.0)
    _guideOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 0),
        weight: _AnimationConfig.guideFadeOutDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(0),
        weight: _AnimationConfig.guideDelayDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1),
        weight: _AnimationConfig.guideFadeInDurationMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1),
        weight: (_AnimationConfig.pulseDurationMs -
                _AnimationConfig.guideFadeInDurationMs)
            .toDouble(),
      ),
    ]).animate(_controller!);

    // Create pulse animation sequence:
    // 0-350ms: no pulse (0.0)
    // 350-850ms: pulse effect (0.0 -> 1.0 -> 0.0)
    _pulseIntensityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0),
        weight: (_AnimationConfig.guideFadeOutDurationMs +
                _AnimationConfig.guideDelayDurationMs)
            .toDouble(),
      ),
      TweenSequenceItem(
        tween: TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0, end: 1),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1, end: 0),
            weight: 50,
          ),
        ]),
        weight: _AnimationConfig.pulseDurationMs.toDouble(),
      ),
    ]).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));

    // Add listener to trigger updates
    _controller!.addListener(onUpdate);
  }

  /// Starts the animation sequence
  void startAnimation() {
    if (_controller != null) {
      _isActive = true;
      // Stop any running animation before starting new one
      if (_controller!.isAnimating) {
        _controller!.stop();
      }
      _controller!.forward().then((_) {
        _isActive = false;
      });
    }
  }

  /// Stops and resets the animation
  void stopAnimation() {
    if (_controller != null) {
      _controller!.stop();
      _controller!.reset();
      _isActive = false;
    }
  }

  /// Disposes of the animation controller
  void dispose() {
    _controller = null;
    _isActive = false;
  }
}

/// Handles rendering logic for desktop trend line preview
class _DesktopRenderer {
  _DesktopRenderer(this._parent);
  final TrendLineAddingPreviewDesktop _parent;

  void renderStartPoint({
    required Canvas canvas,
    required EdgePoint startPoint,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required DrawingPaintStyle paintStyle,
    required LineStyle lineStyle,
    required double pulseIntensity,
  }) {
    // Draw the base start point
    _parent.drawStyledPoint(
        startPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);

    // Draw pulse effect if active
    if (pulseIntensity > 0) {
      final startOffset =
          _parent.edgePointToOffset(startPoint, epochToX, quoteToY);
      final outerRadius = _AnimationConfig.baseRadius +
          (_AnimationConfig.maxGlowRadius - _AnimationConfig.baseRadius) *
              pulseIntensity;

      drawFocusedCircle(
        paintStyle,
        lineStyle,
        canvas,
        startOffset,
        outerRadius,
        _AnimationConfig.baseRadius,
      );
    }
  }

  void renderPreviewLine({
    required Canvas canvas,
    required EdgePoint startPoint,
    required Offset hoverPosition,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required DrawingPaintStyle paintStyle,
    required LineStyle lineStyle,
  }) {
    final startPosition =
        _parent.edgePointToOffset(startPoint, epochToX, quoteToY);
    _parent.drawPreviewLine(
        canvas, startPosition, hoverPosition, paintStyle, lineStyle);
  }

  void renderAlignmentGuides({
    required Canvas canvas,
    required Size size,
    required Offset position,
    required Color lineColor,
    required double opacity,
  }) {
    drawPointAlignmentGuidesWithOpacity(
      canvas,
      size,
      position,
      lineColor: lineColor,
      opacity: opacity,
    );
  }

  void renderEndPoint({
    required Canvas canvas,
    required EdgePoint? endPoint,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required DrawingPaintStyle paintStyle,
    required LineStyle lineStyle,
  }) {
    if (endPoint != null) {
      _parent.drawStyledPoint(
          endPoint, epochToX, quoteToY, canvas, paintStyle, lineStyle);
    }
  }
}

/// Desktop-specific implementation of trend line adding preview with advanced animations.
///
/// This class provides enhanced desktop functionality including:
/// - Animated alignment guide transitions (fade-out → delay → fade-in)
/// - Start point pulse animation with glow effects
/// - Real-time hover feedback with alignment guides
/// - Smooth 60fps animation updates
///
/// The animation sequence triggers when the first point is clicked:
/// 1. 250ms alignment guide fade-out
/// 2. 100ms delay
/// 3. 250ms alignment guide fade-in + 500ms start point pulse (simultaneous)
class TrendLineAddingPreviewDesktop extends TrendLineAddingPreview {
  /// Initializes the desktop trend line adding preview
  TrendLineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 2));
    _renderer = _DesktopRenderer(this);
    _initializeAnimation();
  }

  Offset? _hoverPosition;
  _DesktopAnimationController? _animationController;
  late final _DesktopRenderer _renderer;

  /// Initialize the animation controller using the interactive layer's vsync
  void _initializeAnimation() {
    // Use the interactive layer as the TickerProvider (now has TickerProviderStateMixin)
    final interactiveLayerState = interactiveLayerBehaviour.interactiveLayer;

    // Cast to TickerProvider since we know the implementation has TickerProviderStateMixin
    if (interactiveLayerState is TickerProvider) {
      final tickerProvider = interactiveLayerState as TickerProvider;

      // Create a dedicated AnimationController for our desktop animation
      final controller = AnimationController(
        vsync: tickerProvider,
        duration: const Duration(milliseconds: 850), // Total animation duration
      );

      _animationController = _DesktopAnimationController();
      _animationController!.init(controller, () {
        // Trigger repaint when animation updates
        interactiveLayerBehaviour.onUpdate();
      });
    }
  }

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    final (paintStyle, lineStyle) = getStyles();
    final startPoint = interactableDrawing.startPoint;
    final endPoint = interactableDrawing.endPoint;
    final lineColor = interactableDrawing.config.lineStyle.color;

    if (startPoint != null) {
      _renderWithStartPoint(
        canvas: canvas,
        size: size,
        startPoint: startPoint,
        endPoint: endPoint,
        epochToX: epochToX,
        quoteToY: quoteToY,
        paintStyle: paintStyle,
        lineStyle: lineStyle,
        lineColor: lineColor,
      );
    } else {
      _renderWithoutStartPoint(
        canvas: canvas,
        size: size,
        lineColor: lineColor,
      );
    }
  }

  @override
  void paintOverYAxis(
      Canvas canvas,
      Size size,
      EpochToX epochToX,
      QuoteToY quoteToY,
      EpochFromX? epochFromX,
      QuoteFromY? quoteFromY,
      AnimationInfo animationInfo,
      ChartConfig chartConfig,
      ChartTheme chartTheme,
      GetDrawingState getDrawingState) {
    if (_hoverPosition != null && epochFromX != null && quoteFromY != null) {
      drawPointGuidesAndLabels(
        canvas,
        size,
        _hoverPosition!,
        epochToX,
        quoteToY,
        epochFromX,
        quoteFromY,
        chartConfig,
        chartTheme,
        showGuides: false,
      );
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    final isFirstPoint = interactableDrawing.startPoint == null;

    createPoint(details, epochFromX, quoteFromY);

    if (isFirstPoint) {
      _animationController?.startAnimation();
    }
  }

  void _renderWithStartPoint({
    required Canvas canvas,
    required Size size,
    required EdgePoint startPoint,
    required EdgePoint? endPoint,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required DrawingPaintStyle paintStyle,
    required LineStyle lineStyle,
    required Color lineColor,
  }) {
    // Render start point with pulse effect
    _renderer.renderStartPoint(
      canvas: canvas,
      startPoint: startPoint,
      epochToX: epochToX,
      quoteToY: quoteToY,
      paintStyle: paintStyle,
      lineStyle: lineStyle,
      pulseIntensity: _animationController?.pulseIntensity ?? 0,
    );

    // Render preview line and alignment guides if hovering
    if (_hoverPosition != null) {
      _renderer
        ..renderPreviewLine(
          canvas: canvas,
          startPoint: startPoint,
          hoverPosition: _hoverPosition!,
          epochToX: epochToX,
          quoteToY: quoteToY,
          paintStyle: paintStyle,
          lineStyle: lineStyle,
        )
        ..renderAlignmentGuides(
          canvas: canvas,
          size: size,
          position: _hoverPosition!,
          lineColor: lineColor,
          opacity: _animationController?.guideOpacity ?? 1,
        );
    }

    // Render end point if it exists
    _renderer.renderEndPoint(
      canvas: canvas,
      endPoint: endPoint,
      epochToX: epochToX,
      quoteToY: quoteToY,
      paintStyle: paintStyle,
      lineStyle: lineStyle,
    );
  }

  void _renderWithoutStartPoint({
    required Canvas canvas,
    required Size size,
    required Color lineColor,
  }) {
    if (_hoverPosition != null) {
      _renderer.renderAlignmentGuides(
        canvas: canvas,
        size: size,
        position: _hoverPosition!,
        lineColor: lineColor,
        opacity: _animationController?.guideOpacity ?? 1,
      );
    }
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
