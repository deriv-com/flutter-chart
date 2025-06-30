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
import 'horizontal_line_interactable_drawing.dart';

/// A class to show a preview and handle adding
/// [HorizontalLineInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour]
class HorizontalLineAddingPreviewDesktop
    extends DrawingAddingPreview<HorizontalLineInteractableDrawing> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineAddingPreviewDesktop({
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
  String get id => 'Horizontal-line-adding-preview-desktop';

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
      final double lineY = _hoverPosition!.dy;

      final Path horizontalPath = Path()
        ..moveTo(0, lineY)
        ..lineTo(size.width, lineY);

      canvas.drawPath(
        dashPath(horizontalPath,
            dashArray: CircularIntervalList<double>(<double>[2, 2])),
        Paint()
          ..color = interactableDrawing.config.lineStyle.color
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
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (_hoverPosition != null) {
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: interactiveLayerBehaviour.interactiveLayer
            .quoteFromY(_hoverPosition!.dy),
        pipSize: chartConfig.pipSize,
        size: size,
        color: interactableDrawing.config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        textStyle: interactableDrawing.config.labelStyle,
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
