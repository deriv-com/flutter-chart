import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_selected_tool_state.dart';
import 'package:flutter/animation.dart';

import '../chart/data_visualization/chart_data.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactive_layer_states/interactive_normal_state.dart';
import 'enums/state_change_direction.dart';

/// The interactive layer base class interface.
abstract class InteractiveLayerBase {
  /// Updates the state of the interactive layer to the [state].
  ///
  /// The [direction] defines the possible animation direction of the state
  /// change. for example from [InteractiveNormalState] to
  /// [InteractiveSelectedToolState] can be forward
  /// and from [InteractiveSelectedToolState] to [InteractiveNormalState] can be
  /// backward. so the [InteractiveLayerBase] can animate the transition
  /// accordingly.
  Future<void> animateStateChange(
    StateChangeAnimationDirection direction, {
    bool animate = true,
  });

  /// The drawings of the interactive layer.
  List<InteractableDrawing<DrawingToolConfig>> get drawings;

  /// The animation controller that [InteractiveLayerBase] can have to play
  /// state change animations. Like selecting a drawing tool.
  AnimationController? get stateChangeAnimationController;

  /// Converts x to epoch.
  EpochFromX get epochFromX;

  /// Converts y to quote.
  QuoteFromY get quoteFromY;

  /// Converts epoch to x.
  EpochToX get epochToX;

  /// Converts quote to y.
  QuoteToY get quoteToY;

  /// The size of the interactive layer.
  DrawingContext get drawingContext;

  /// Clears the adding drawing.
  void clearAddingDrawing();

  /// Adds the [drawing] to the interactive layer.
  DrawingToolConfig addDrawing(DrawingToolConfig drawing);

  /// Save the drawings with the latest changes (positions or anything) to the
  /// repository.
  void saveDrawing(DrawingToolConfig drawing);

  /// Removes the [drawing] from the interactive layer and the chart.
  void removeDrawing(DrawingToolConfig drawing);

  /// Hides the crosshair if it's currently active.
  ///
  /// This method provides a clean way to hide the crosshair when other
  /// UI elements need to take precedence over crosshair interactions.
  void hideCrosshair();
}
