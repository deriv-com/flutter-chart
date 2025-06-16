import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../enums/state_change_direction.dart';
import '../interactable_drawings/interactable_drawing.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_selected_tool_state.dart';
import 'interactive_state.dart';

/// Represents the information about the tool being added to the interactive
/// layer.
class AddingStateInfo {
  /// Creates an instance of [AddingStateInfo].
  AddingStateInfo({
    required this.addingTool,
    required this.step,
  }) : addingToolType = addingTool.runtimeType;

  /// The type of the tool being added.
  final Type addingToolType;

  /// The configuration of the tool being added.
  final InteractableDrawing<DrawingToolConfig> addingTool;

  /// Indicates the current step in the process of adding a tool.
  final AddingToolStep step;

  /// Creates a copy of this [AddingStateInfo] with the specified
  /// [addingTool] and [step].
  AddingStateInfo copyWith({
    InteractableDrawing<DrawingToolConfig>? addingTool,
    AddingToolStep? step,
  }) =>
      AddingStateInfo(
        addingTool: addingTool ?? this.addingTool,
        step: step ?? this.step,
      );
}

/// Represents a step in the process of adding a tool to the interactive layer,
/// indicating which point the user is expected to set.
class AddingToolStep {
  const AddingToolStep._(this.step);

  /// Creates a step where the layer is expecting the user to add the Nth point
  /// of the tool.
  ///
  /// This can be used for tools that require more than two points.
  factory AddingToolStep.awaitingPointN(int pointN) => AddingToolStep._(pointN);

  /// The code of the step.
  final int step;

  /// The layer is expecting the user to add the first point of the tool.
  static const awaitingFirstPoint = AddingToolStep._(1);

  /// The layer is expecting the user to add the second point of the tool,
  /// which is typically the endpoint for most tools.
  static const awaitingEndPoint = AddingToolStep._(2);

  /// The layer is expecting the user to add a single point for the tool.
  ///
  /// Some tools, such as [HorizontalLineInteractableDrawing], require only one
  /// point only.
  static const awaitingTheOnlyPoint = AddingToolStep._(0);

  /// Indicates that the tool addition process is awaiting the user to confirm
  /// the addition of the tool.
  static const awaitingFinishAdding = AddingToolStep._(-1);

  /// The users has finished adding the tool.
  static const addingFinished = AddingToolStep._(-2);

  @override
  String toString() => 'AddingToolStep(step: $step)';
}

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
    _drawingPreview ??= interactiveLayerBehaviour.getAddingDrawingPreview(
      addingTool.getInteractableDrawing(
        interactiveLayerBehaviour.interactiveLayer.drawingContext,
        interactiveLayerBehaviour.getToolState,
      ),
    );

    addingStateInfo = _drawingPreview!.addingStateInfo;
  }

  /// The initial state information for adding a tool.
  late final AddingStateInfo addingStateInfo;

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
    _drawingPreview!.onCreateTap(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
      onAddingStateChange: (addingStateInfo) {
        interactiveLayerBehaviour.controller.currentState = this.copyWith(
          addingTool: _drawingPreview!.interactableDrawing,
          step: addingStateInfo.step,
        );

        if (addingStateInfo.step == AddingToolStep.addingFinished) {
          interactiveLayer
            ..clearAddingDrawing()
            ..addDrawing(
                _drawingPreview!.interactableDrawing.getUpdatedConfig());

          // Update the state to selected tool state with the newly added drawing.
          //
          // Once we have saved the drawing config in [AddOnsRepository] we should
          // update to selected state with the interactable drawing that comes from
          // that configs and not the preview one.
          interactiveLayerBehaviour.updateStateTo(
            InteractiveSelectedToolState(
              selected: _drawingPreview!.interactableDrawing,
              interactiveLayerBehaviour: interactiveLayerBehaviour,
            ),
            StateChangeAnimationDirection.forward,
          );

          _drawingPreview = null;
        }
      },
    );
  }
}
