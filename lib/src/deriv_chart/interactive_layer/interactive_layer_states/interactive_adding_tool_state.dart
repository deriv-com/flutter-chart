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

/// Represents the information about progress of the tool being added to the
/// interactive layer.
class AddingStateInfo {
  /// Creates an instance of [AddingStateInfo].
  AddingStateInfo(this.currentStep, this.totalSteps);

  /// The current step of the adding process of a [DrawingAddingPreview].
  final int currentStep;

  /// The total number of steps required to complete the adding process.
  final int totalSteps;

  /// Indicates whether the adding process is finished.
  bool get isFinished => currentStep == totalSteps;

  @override
  String toString() =>
      'AddingStateInfo(currentStep: $currentStep, totalSteps: $totalSteps)';
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
      _onAddingStateChange,
    );
  }

  void _onAddingStateChange(
    AddingStateInfo addingStateInfo,
  ) {
    _addingStateInfo = addingStateInfo;
    interactiveLayerBehaviour.updateStateTo(
      this,
      StateChangeAnimationDirection.forward,
      animate: false,
    );

    if (addingStateInfo.isFinished) {
      interactiveLayer
        ..clearAddingDrawing()
        ..addDrawing(_drawingPreview!.interactableDrawing.getUpdatedConfig());

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
  }

  /// The initial state information for adding a tool.
  AddingStateInfo? _addingStateInfo;

  /// Getter to get the [_addingStateInfo] instance.
  AddingStateInfo? get addingStateInfo => _addingStateInfo;

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
    final String? addingDrawingId = _drawingPreview?.interactableDrawing.id;

    final Set<DrawingToolState> states = drawing.id == addingDrawingId
        ? {DrawingToolState.adding}
        : {DrawingToolState.normal};

    return states;
  }

  @override
  bool onPanEnd(DragEndDetails details) {
    if (_isAddingToolBeingDragged) {
      _drawingPreview?.onDragEnd(
          details, epochFromX, quoteFromY, epochToX, quoteToY);

      _isAddingToolBeingDragged = false;
      return true; // Ended dragging the tool being added. Jim - Verify this
    }

    // To trigger the animation of the interactive layer, so the adding preview
    // can perform its revers dragging effect animation.
    interactiveLayerBehaviour.updateStateTo(
      this,
      StateChangeAnimationDirection.backward,
    );
    return false; // Not dragging the tool being added. Jim - Verify this
  }

  @override
  bool onPanStart(DragStartDetails details) {
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
      return true; // Started dragging the tool being added. Jim - Verify this
    } else {
      _isAddingToolBeingDragged = false;
      return false; // Not dragging the tool being added. Jim - Verify this
    }
  }

  @override
  bool onPanUpdate(DragUpdateDetails details) {
    if (_isAddingToolBeingDragged) {
      _drawingPreview?.onDragUpdate(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );
      return true; // Dragging the adding tool. Jim - Verify this
    }
    return false; // Not dragging the adding tool. Jim - Verify this
  }

  @override
  bool onHover(PointerHoverEvent event) {
    _drawingPreview?.onHover(
      event,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );

    return true; // Always return true as we're in adding mode
  }

  @override
  bool onTap(TapUpDetails details) {
    _drawingPreview!.onCreateTap(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
    return true; // Always return true as we're in adding mode
  }
}
