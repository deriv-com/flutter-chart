import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/horizontal_line/horizontal_line_adding_preview_desktop.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/widgets/color_picker/color_picker_dropdown_button.dart';
import 'package:deriv_chart/src/widgets/dropdown/line_thickness/line_thickness_dropdown_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../enums/drawing_tool_state.dart';
import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'horizontal_line_adding_preview_mobile.dart';

/// Interactable drawing for horizontal line drawing tool.
class HorizontalLineInteractableDrawing
    extends InteractableDrawing<HorizontalDrawingToolConfig> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineInteractableDrawing({
    required HorizontalDrawingToolConfig config,
    required this.startPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// Start point of the line.
  EdgePoint? startPoint;

  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null) {
      return;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the drag is near the line
    final double distance = (details.localPosition.dy - startOffset.dy).abs();
    if (distance > hitTestMargin) {
      return;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null) {
      return false;
    }

    final isNotSelected = !state.contains(DrawingToolState.selected);

    final isOutsideContent = offset.dx > drawingContext.contentSize.width;

    if (isNotSelected && isOutsideContent) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the point is near the line's y-coordinate
    final double distance = (offset.dy - startOffset.dy).abs();
    return distance <= hitTestMargin;
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
    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    if (startPoint != null) {
      final Offset startOffset =
          Offset(0, quoteToY(startPoint!.quote)); // Start from left edge
      final Offset endOffset =
          Offset(size.width, quoteToY(startPoint!.quote)); // End at right edge

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint =
          paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);

      canvas.drawLine(startOffset, endOffset, paint);

      if (drawingState.contains(DrawingToolState.selected)) {
        final neonPain = Paint()
          ..color = config.lineStyle.color.withOpacity(0.4)
          ..strokeWidth = 8 * animationInfo.stateChangePercent
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawLine(startOffset, endOffset, neonPain);
      }
    } else {
      if (startPoint == null && _hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview horizontal line from startPoint's y-coordinate
        final Offset startPosition = Offset(
          0,
          _hoverPosition!.dy,
        );
        final Offset endPosition = Offset(
          size.width,
          _hoverPosition!.dy,
        );
        canvas.drawLine(startPosition, endPosition,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));
        drawPointAlignmentGuides(canvas, size, startPosition);
      }
    }
  }

  @override
  void paintOverYAxis(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    EpochFromX? epochFromX,
    QuoteFromY? quoteFromY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (getDrawingState(this).contains(DrawingToolState.selected)) {
      drawValueLabel(
        canvas: canvas,
        quoteToY: quoteToY,
        value: startPoint!.quote,
        pipSize: chartConfig.pipSize,
        animationProgress: animationInfo.stateChangePercent,
        size: size,
        textStyle: config.labelStyle,
        color: config.lineStyle.color,
        backgroundColor: chartTheme.backgroundColor,
        addNeonEffect: true,
      );
    }
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final double deltaY = details.delta.dy;

    // Get the current screen position
    final double currentY = quoteToY(startPoint!.quote);

    // Apply the delta to get the new screen position
    final double newY = currentY + deltaY;

    // Convert back to quote coordinate
    final double newQuote = quoteFromY(newY);

    // Update both points to maintain horizontal line
    startPoint = EdgePoint(
      epoch: startPoint!.epoch,
      quote: newQuote,
    );
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // No special handling needed for drag end
  }

  @override
  HorizontalDrawingToolConfig getUpdatedConfig() => config
      .copyWith(edgePoints: <EdgePoint>[if (startPoint != null) startPoint!]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      // On X-axis range horizontal line is always visible
      // TODO(NA): consider Y-axis (quoteRange) checking when finding a solution
      // to clear dismiss the existing drawing, if main series is changed and the
      // tool is not supposed to be visible because it's outside of view-port.
      // For now it won't impact that much in terms of performance, since the
      // number tools we allow to add in total is limited to a few.
      true;

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
          HorizontalLineAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
            onAddingStateChange: onAddingStateChange,
          );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
          HorizontalLineAddingPreviewMobile(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
            onAddingStateChange: onAddingStateChange,
          );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
        children: <Widget>[
          _buildLineThicknessIcon(onUpdate),
          const SizedBox(width: 4),
          _buildColorPickerIcon(onUpdate)
        ],
      );

  Widget _buildColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
        width: 32,
        height: 32,
        child: ColorPickerDropdownButton(
          currentColor: config.lineStyle.color,
          onColorChanged: (newColor) => onUpdate(config.copyWith(
            lineStyle: config.lineStyle.copyWith(color: newColor),
            labelStyle: config.labelStyle.copyWith(color: newColor),
          )),
        ),
      );

  Widget _buildLineThicknessIcon(UpdateDrawingTool onUpdate) =>
      LineThicknessDropdownButton(
        thickness: config.lineStyle.thickness,
        onValueChanged: (double newValue) {
          onUpdate(config.copyWith(
            lineStyle: config.lineStyle.copyWith(thickness: newValue),
          ));
        },
      );
}
