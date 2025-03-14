import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:flutter/gestures.dart';

import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_base.dart';

/// The state of the interactive layer.
///
/// This abstract class defines the interface for different states that the [InteractiveLayer]
/// can be in. It allows the interactive layer to change its behavior dynamically by
/// switching between different states.
///
/// There are three main states implemented:
/// * [InteractiveNormalState]: The default state where no tools are selected or being added
/// * [InteractiveSelectedToolState]: Activated when a tool is selected, enabling manipulation
/// * [InteractiveAddingToolState]: Active when a new tool is being created
///
/// Each state handles user interactions (tap, pan events) differently and can transition
/// to other states using [InteractiveLayerBase.updateStateTo].
abstract class InteractiveState {
  /// Initializes the state with the interactive layer.
  ///
  /// The [interactiveLayer] parameter provides a reference to the layer that owns
  /// this state, allowing the state to call methods on the layer such as updating
  /// to a new state or adding/saving drawings.
  InteractiveState({required this.interactiveLayer});

  /// Returns the state of the drawing tool.
  ///
  /// This method determines the visual and behavioral state of a specific drawing tool.
  /// Each concrete state implementation returns different [DrawingToolState] values:
  Set<DrawingToolState> getToolState(
    InteractableDrawing<DrawingToolConfig> drawing,
  );

  /// Additional drawings of the state to be drawn on top of the main drawings.
  ///
  /// Returns a list of additional drawings specific to the current state.
  /// The default implementation returns an empty list, but subclasses can override
  /// this to provide state-specific drawings (e.g., a tool being added in
  /// [InteractiveAddingToolState]).
  ///
  /// These are usually temporary/preview drawings that a state might want to
  /// render on top of the main drawings.
  List<InteractableDrawing<DrawingToolConfig>> get previewDrawings => [];

  /// The interactive layer.
  ///
  /// A reference to the layer that owns this state, allowing the state to
  /// access layer properties and methods.
  final InteractiveLayerBase interactiveLayer;

  /// Converts x coordinate (in pixels) to epoch timestamp.
  ///
  /// This is a convenience getter that provides access to the coordinate
  /// conversion function from the interactive layer.
  EpochFromX get epochFromX => interactiveLayer.epochFromX;

  /// Converts y coordinate (in pixels) to quote value.
  ///
  /// This is a convenience getter that provides access to the coordinate
  /// conversion function from the interactive layer.
  QuoteFromY get quoteFromY => interactiveLayer.quoteFromY;

  /// Converts epoch timestamp to x coordinate (in pixels).
  ///
  /// This is a convenience getter that provides access to the coordinate
  /// conversion function from the interactive layer.
  EpochToX get epochToX => interactiveLayer.epochToX;

  /// Converts quote value to y coordinate (in pixels).
  ///
  /// This is a convenience getter that provides access to the coordinate
  /// conversion function from the interactive layer.
  QuoteToY get quoteToY => interactiveLayer.quoteToY;

  /// Handles tap event.
  void onTap(TapUpDetails details) {}

  /// Handles pan update event.
  void onPanUpdate(DragUpdateDetails details) {}

  /// Handles pan end event.
  void onPanEnd(DragEndDetails details) {}

  /// Handles pan start event.
  void onPanStart(DragStartDetails details) {}

  /// Handles hover event.
  void onHover(PointerHoverEvent event) {}
}

/// Extension that provides utility methods for interactive states.
extension InteractiveStateExtension on InteractiveState {
  /// Returns the drawing that was hit by the tap event.
  /// Returns null if no drawing was hit.
  InteractableDrawing<DrawingToolConfig>? anyDrawingHit(Offset hitOffset) {
    for (final drawing in interactiveLayer.drawings) {
      if (drawing.hitTest(
        hitOffset,
        epochToX,
        quoteToY,
      )) {
        return drawing;
      }
    }
    return null;
  }
}
