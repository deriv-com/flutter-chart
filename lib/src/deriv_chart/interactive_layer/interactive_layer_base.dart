import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_states/interactive_selected_tool_state.dart';

import '../chart/data_visualization/chart_data.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactive_states/interactive_state.dart';
import 'state_change_direction.dart';

/// The interactive layer base class interface.
abstract class InteractiveLayerBase {
  /// Updates the state of the interactive layer to the [state].
  ///
  /// The [direction] defines the possible animation direction of the state
  /// change. for example from [InteractiveNormalState] to
  /// [InteractiveSelectedToolState] can be forward
  /// and from [InteractiveSelectedToolState] to [InteractiveNormalState] can be
  /// backward. so the [InteractiveLayerBase] can animate the transition accordingly.
  ///
  /// The [waitForAnimation] defines if interactive layer should wait for the
  /// animation to finish before changing to the new state or should change
  /// to the new state right away.
  void updateStateTo(
    InteractiveState state,
    StateChangeAnimationDirection direction, {
    bool waitForAnimation = false,
  });

  /// The drawings of the interactive layer.
  List<InteractableDrawing<DrawingToolConfig>> get drawings;

  /// Converts x to epoch.
  EpochFromX get epochFromX;

  /// Converts y to quote.
  QuoteFromY get quoteFromY;

  /// Converts epoch to x.
  EpochToX get epochToX;

  /// Converts quote to y.
  QuoteToY get quoteToY;

  /// Clears the adding drawing.
  void clearAddingDrawing();

  /// Adds the [drawing] to the interactive layer.
  DrawingToolConfig onAddDrawing(
      InteractableDrawing<DrawingToolConfig> drawing);

  /// Save the drawings with the latest changes (positions or anything) to the
  /// repository.
  void onSaveDrawing(InteractableDrawing<DrawingToolConfig> drawing);
}
