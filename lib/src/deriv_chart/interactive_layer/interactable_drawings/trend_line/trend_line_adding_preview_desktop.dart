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

/// Manages animation state and values for desktop trend line preview
class _DesktopAnimationController {
  DesktopAnimationState _state = DesktopAnimationState.idle;
  DateTime? _startTime;
  bool _isActive = false;

  double _guideOpacity = 1;
  double _pulseIntensity = 0;

  /// Current animation state
  DesktopAnimationState get state => _state;

  /// Whether animation is currently active
  bool get isActive => _isActive;

  /// Current opacity for alignment guides
  double get guideOpacity => _guideOpacity;

  /// Current pulse intensity for start point glow
  double get pulseIntensity => _pulseIntensity;

  /// Starts the animation sequence
  void startAnimation() {
    _state = DesktopAnimationState.guideFadeOut;
    _startTime = DateTime.now();
    _isActive = true;
  }

  /// Stops and resets the animation
  void stopAnimation() {
    _state = DesktopAnimationState.idle;
    _startTime = null;
    _isActive = false;
    _guideOpacity = 1;
    _pulseIntensity = 0;
  }

  /// Updates animation values based on elapsed time
  void update() {
    if (_startTime == null || _state == DesktopAnimationState.idle) {
      return;
    }

    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;

    switch (_state) {
      case DesktopAnimationState.guideFadeOut:
        _updateFadeOut(elapsed);
        break;
      case DesktopAnimationState.guideDelay:
        _updateDelay(elapsed);
        break;
      case DesktopAnimationState.guideFadeIn:
        _updateFadeInWithPulse(elapsed);
        break;
      case DesktopAnimationState.startPointPulse:
      case DesktopAnimationState.idle:
        break;
    }
  }

  void _updateFadeOut(int elapsed) {
    final progress =
        (elapsed / _AnimationConfig.guideFadeOutDurationMs).clamp(0.0, 1.0);
    _guideOpacity = 1.0 - progress;

    if (progress >= 1.0) {
      _state = DesktopAnimationState.guideDelay;
    }
  }

  void _updateDelay(int elapsed) {
    if (elapsed >= _AnimationConfig.guideDelayDurationMs) {
      _state = DesktopAnimationState.guideFadeIn;
    }
  }

  void _updateFadeInWithPulse(int elapsed) {
    const fadeInStart = _AnimationConfig.guideDelayDurationMs;
    final fadeInElapsed = elapsed - fadeInStart;
    final fadeProgress =
        (fadeInElapsed / _AnimationConfig.guideFadeInDurationMs)
            .clamp(0.0, 1.0);

    // Update guide opacity
    _guideOpacity = fadeProgress;

    // Update pulse animation simultaneously
    final pulseElapsed = elapsed - fadeInStart;
    final pulseProgress =
        (pulseElapsed / _AnimationConfig.pulseDurationMs).clamp(0.0, 1.0);

    // Create pulse effect: 0 -> 1 -> 0
    if (pulseProgress <= 0.5) {
      _pulseIntensity = pulseProgress * 2.0;
    } else {
      _pulseIntensity = (1.0 - pulseProgress) * 2.0;
    }

    // Animation completes when both fade-in and pulse are done
    if (fadeProgress >= 1.0 && pulseProgress >= 1.0) {
      _pulseIntensity = 0.0;
      _state = DesktopAnimationState.idle;
      _isActive = false;
    }
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
  }
  Offset? _hoverPosition;
  final _animationController = _DesktopAnimationController();
  late final _DesktopRenderer _renderer;

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
    _updateAnimation();

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
      _animationController.startAnimation();
      _scheduleNextFrame();
    }
  }

  void _updateAnimation() {
    _animationController.update();

    if (_animationController.isActive) {
      _scheduleNextFrame();
    }
  }

  void _scheduleNextFrame() {
    Future.microtask(() {
      if (_animationController.isActive) {
        interactiveLayerBehaviour.onUpdate();
      }
    });
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
      pulseIntensity: _animationController.pulseIntensity,
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
          opacity: _animationController.guideOpacity,
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
        opacity: _animationController.guideOpacity,
      );
    }
  }

  @override
  String get id => 'line-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;
}
