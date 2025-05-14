import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../enums/state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_selected_tool_state.dart';
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
    _addingDrawing ??= interactiveLayerBehaviour
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
  DrawingAddingPreview? _addingDrawing;

  /// Getter to get the adding drawing preview instance.
  DrawingAddingPreview? get addingDrawingPreview => _addingDrawing;


  @override
  List<DrawingV2> get previewDrawings =>
      [if (_addingDrawing != null) _addingDrawing!];

  @override
  Set<DrawingToolState> getToolState(DrawingV2 drawing) {
    final String? addingDrawingId = _addingDrawing != null
        ? interactiveLayerBehaviour
            .getAddingDrawingPreview(_addingDrawing!.interactableDrawing)
            .id
        : null;

    final Set<DrawingToolState> states = drawing.id == addingDrawingId
        ? {
            DrawingToolState.adding,
            if (_isAddingToolBeingDragged) DrawingToolState.dragging
          }
        : {DrawingToolState.idle};

    return states;
  }

  @override
  void onPanEnd(DragEndDetails details) {
    if (_isAddingToolBeingDragged) {
      _isAddingToolBeingDragged = false;
    }

    if (_addingDrawing?.hitTest(details.localPosition, epochToX, quoteToY) ??
        false) {
      _addingDrawing!
          .onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
    }
  }

  @override
  void onPanStart(DragStartDetails details) {
    if (_addingDrawing?.hitTest(details.localPosition, epochToX, quoteToY) ??
        false) {
      _isAddingToolBeingDragged = true;
      _addingDrawing!.onDragStart(
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
    if (_addingDrawing != null) {
      if (_addingDrawing!.hitTest(details.localPosition, epochToX, quoteToY)) {
        _addingDrawing!.onDragUpdate(
          details,
          epochFromX,
          quoteFromY,
          epochToX,
          quoteToY,
        );
      }
    }
  }

  @override
  void onHover(PointerHoverEvent event) {
    _addingDrawing?.onHover(
      event,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onTap(TapUpDetails details) {
    _addingDrawing!
        .onCreateTap(details, epochFromX, quoteFromY, epochToX, quoteToY, () {
      interactiveLayer.clearAddingDrawing();

      final DrawingToolConfig addedConfig =
          interactiveLayer.onAddDrawing(_addingDrawing!.interactableDrawing);

      for (final drawing in interactiveLayer.drawings) {
        if (drawing.config.configId == addedConfig.configId) {
          interactiveLayerBehaviour.updateStateTo(
            InteractiveSelectedToolState(
              selected: drawing,
              interactiveLayerBehaviour: interactiveLayerBehaviour,
            ),
            StateChangeAnimationDirection.forward,
          );
          break;
        }
      }
    });
  }
}
