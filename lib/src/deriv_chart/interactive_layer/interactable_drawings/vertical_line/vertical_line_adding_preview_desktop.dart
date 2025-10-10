import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'vertical_line_interactable_drawing.dart';

/// A class to show a preview and handle adding
/// [VerticalLineInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour]
class VerticalLineAddingPreviewDesktop
    extends DrawingAddingPreview<VerticalLineInteractableDrawing> {
  /// Initializes [VerticalLineInteractableDrawing].
  VerticalLineAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 1));
  }

  Offset? _hoverPosition;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  String get id => 'Vertical-line-adding-preview-desktop';

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState drawingState,
  ) {
    if (_hoverPosition != null) {
      final double lineX = _hoverPosition!.dx;

      final Path verticalPath = Path()
        ..moveTo(lineX, 0)
        ..lineTo(lineX, size.height);

      canvas.drawPath(
        dashPath(verticalPath,
            dashArray: CircularIntervalList<double>(<double>[2, 2])),
        Paint()
          ..color = interactableDrawing.config.lineStyle.color
          ..strokeWidth = interactableDrawing
              .config.lineStyle.thickness // Explicitly set for consistency
          ..style = PaintingStyle.stroke,
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
    GetDrawingState getDrawingState,
  ) {
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

  /// Draws alignment guides and labels for a point during interactions.
  void drawPointGuidesAndLabels(
    Canvas canvas,
    Size size,
    Offset pointOffset,
    EpochToX epochToX,
    QuoteToY quoteToY,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    ChartConfig chartConfig,
    ChartTheme chartTheme, {
    bool showGuides = true,
    bool showLabels = true,
  }) {
    if (showGuides) {
      drawPointAlignmentGuides(
        canvas,
        size,
        pointOffset,
        lineColor: interactableDrawing.config.lineStyle.color,
      );
    }

    if (showLabels) {
      final int epoch = epochFromX(pointOffset.dx);

      // Draw epoch label at the bottom
      drawEpochLabel(
        canvas: canvas,
        epochToX: epochToX,
        epoch: epoch,
        size: size,
        textStyle: interactableDrawing.config.labelStyle,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
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
    if (interactableDrawing.startPoint == null) {
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(1, 1));
    }
  }
}
