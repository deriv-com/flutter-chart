import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/paint_helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'horizontal_line_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [HorizontalLineInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
class HorizontalLineAddingPreviewMobile
    extends DrawingAddingPreview<HorizontalLineInteractableDrawing> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      final double centerX = layerSize != null ? layerSize.width / 2 : 0;
      final double centerY = layerSize != null ? layerSize.height / 2 : 0;

      interactableDrawing.startPoint = EdgePoint(
        epoch: interactiveLayer.epochFromX(centerX),
        quote: interactiveLayer.quoteFromY(centerY),
      );

      onAddingStateChange(AddingStateInfo(0, 1));
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    // TODO(NA): To be more accurate, implement a hitTest specific for preview
    // instead of relying on its interactable drawing.
    return interactableDrawing.hitTest(offset, epochToX, quoteToY);
  }

  @override
  String get id => 'Horizontal-line-adding-preview-mobile';

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragUpdate(DragUpdateDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
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
    GetDrawingState drawingState,
  ) {
    if (interactableDrawing.startPoint != null) {
      final double lineY = quoteToY(interactableDrawing.startPoint!.quote);

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
    drawValueLabel(
      canvas: canvas,
      quoteToY: quoteToY,
      value: interactableDrawing.startPoint!.quote,
      pipSize: chartConfig.pipSize,
      size: size,
      textStyle: interactableDrawing.config.labelStyle,
      color: interactableDrawing.config.lineStyle.color,
      backgroundColor: chartTheme.backgroundColor,
    );
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    interactableDrawing.startPoint ??= EdgePoint(
      epoch: epochFromX(details.localPosition.dx),
      quote: quoteFromY(details.localPosition.dy),
    );

    onAddingStateChange(AddingStateInfo(1, 1));
  }
}
