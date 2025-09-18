import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../enums/drawing_tool_state.dart';
import '../helpers/types.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_base.dart';
import '../interactive_layer_behaviours/interactive_layer_behaviour.dart';

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
  InteractiveState({required this.interactiveLayerBehaviour});

  /// Returns the state of the drawing tool.
  ///
  /// This method determines the visual and behavioral state of a specific drawing tool.
  /// Each concrete state implementation returns different [DrawingToolState] values:
  Set<DrawingToolState> getToolState(DrawingV2 drawing);

  /// Returns the z-order for the tool drawings.
  DrawingZOrder getToolZOrder(DrawingV2 drawing) => DrawingZOrder.bottom;

  /// Additional drawings of the state to be drawn on top of the main drawings.
  ///
  /// Returns a list of additional drawings specific to the current state.
  /// The default implementation returns an empty list, but subclasses can override
  /// this to provide state-specific drawings (e.g., a tool being added in
  /// [InteractiveAddingToolState]).
  ///
  /// These are usually temporary/preview drawings that a state might want to
  /// render on top of the main drawings.
  List<DrawingV2> get previewDrawings => [];

  /// Additional widgets to be rendered on top of the interactive layer.
  List<Widget> get previewWidgets => [];

  /// The interactive layer.
  ///
  /// A reference to the layer that owns this state, allowing the state to
  /// access layer properties and methods.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// The interactive layer that owns this state.
  InteractiveLayerBase get interactiveLayer =>
      interactiveLayerBehaviour.interactiveLayer;

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
  /// Returns true if the tap was handled by a drawing tool, false otherwise.
  bool onTap(TapUpDetails details) {
    // Default implementation returns false
    // Subclasses can override this to provide specific tap handling logic
    return false;
  }

  /// Handles pan update event.
  /// Returns true if the pan update is affecting a drawing tool, false otherwise.
  bool onPanUpdate(DragUpdateDetails details) {
    // Default implementation returns false
    // Subclasses can override this to provide specific pan update handling logic
    return false;
  }

  /// Handles pan end event.
  /// Returns true if the pan end is affecting a drawing tool, false otherwise.
  bool onPanEnd(DragEndDetails details) {
    // Default implementation returns false
    // Subclasses can override this to provide specific pan end handling logic
    return false;
  }

  /// Handles pan start event.
  /// Returns true if the pan was started on a drawing tool, false otherwise.
  bool onPanStart(DragStartDetails details) {
    // Default implementation returns false
    // Subclasses can override this to provide specific pan start handling logic
    return false;
  }

  /// Handles hover event.
  /// Returns true if the hover is over a drawing tool, false otherwise.
  bool onHover(PointerHoverEvent event) {
    // Default implementation returns false
    // Subclasses can override this to provide specific hover handling logic
    return false;
  }

  /// Handles long press event.
  /// Returns true if the long press was handled by a drawing tool, false otherwise.
  bool onLongPress(Offset localPosition) {
    // Default implementation returns false
    // Subclasses can override this to provide specific long press handling logic
    return false;
  }

  /// Handles long press end event.
  /// Returns true if the long press end was handled by a drawing tool, false otherwise.
  bool onLongPressEnd() {
    // Default implementation returns false
    // Subclasses can override this to provide specific long press end handling logic
    return false;
  }
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
