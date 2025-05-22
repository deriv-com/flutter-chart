import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../enums/state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_state.dart';

/// The state of the interactive layer when a tool is being added.
///
/// This class represents the state of the [InteractiveLayer] when a new drawing tool
/// is being added to the chart. In this state, tapping on the chart will create a new
/// drawing of the specified type.
///
/// After the drawing is created, the interactive layer transitions back to the
/// [InteractiveNormalState].
class InteractiveAddingToolState extends InteractiveState
    with InteractiveHoverState {
  /// Initializes the state with the interactive layer and the [addingTool].
  ///
  /// The [addingTool] parameter specifies the configuration for the type of drawing
  /// tool that will be created when the user taps on the chart.
  ///
  /// The [interactiveLayer] parameter is passed to the superclass and provides
  /// access to the layer's methods and properties.
  InteractiveAddingToolState(
    this.addingTool, {
    required super.interactiveLayerBehaviour,
  }) {
    _drawingPreview ??= interactiveLayerBehaviour
        .getAddingDrawingPreview(addingTool.getInteractableDrawing());
  }

  /// The tool being added.
  ///
  /// This configuration defines the type of drawing that will be created
  /// when the user taps on the chart.
  final DrawingToolConfig addingTool;

  bool _isAddingToolBeingDragged = false;

  /// The drawing that is currently being created.
  ///
  /// This is initialized when the user first taps on the chart and is used
  /// to render a preview of the drawing being added.
  DrawingAddingPreview? _drawingPreview;

  /// Getter to get the [_drawingPreview] instance.
  DrawingAddingPreview? get addingDrawingPreview => _drawingPreview;

  @override
  List<DrawingV2> get previewDrawings =>
      [if (_drawingPreview != null) _drawingPreview!];

  @override
  Set<DrawingToolState> getToolState(DrawingV2 drawing) {
    final String? addingDrawingId = _drawingPreview != null
        ? interactiveLayerBehaviour
            .getAddingDrawingPreview(_drawingPreview!.interactableDrawing)
            .id
        : null;

    final Set<DrawingToolState> states = drawing.id == addingDrawingId
        ? {
            DrawingToolState.adding,
            if (_isAddingToolBeingDragged) DrawingToolState.dragging
          }
        : {DrawingToolState.normal};

    return states;
  }

  @override
  void onPanEnd(DragEndDetails details) {
    if (_isAddingToolBeingDragged) {
      _drawingPreview?.onDragEnd(
          details, epochFromX, quoteFromY, epochToX, quoteToY);

      _isAddingToolBeingDragged = false;
    }

    // To trigger the animation of the interactive layer, so the adding preview
    // can perform its revers dragging effect animation.
    interactiveLayerBehaviour.updateStateTo(
      this,
      StateChangeAnimationDirection.backward,
    );
  }

  @override
  void onPanStart(DragStartDetails details) {
    if (_drawingPreview?.hitTest(details.localPosition, epochToX, quoteToY) ??
        false) {
      // To trigger the animation of the interactive layer, so the adding
      // preview can perform its forward dragging effect animation.
      interactiveLayerBehaviour.updateStateTo(
        this,
        StateChangeAnimationDirection.forward,
      );

      _isAddingToolBeingDragged = true;
      _drawingPreview!.onDragStart(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );
    } else {
      _isAddingToolBeingDragged = false;
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (_isAddingToolBeingDragged) {
      _drawingPreview?.onDragUpdate(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );
    }
  }

  @override
  void onHover(PointerHoverEvent event) {
    _drawingPreview?.onHover(
      event,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onTap(TapUpDetails details) {
    _drawingPreview!
        .onCreateTap(details, epochFromX, quoteFromY, epochToX, quoteToY, () {
      interactiveLayerBehaviour.updateStateTo(
        InteractiveNormalState(
          interactiveLayerBehaviour: interactiveLayerBehaviour,
        ),
        StateChangeAnimationDirection.forward,
      );

      interactiveLayer
        ..clearAddingDrawing()
        ..addDrawing(_drawingPreview!.interactableDrawing);
    });
  }
}
