import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_states/interactive_normal_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_states/interactive_selected_tool_state.dart';

/// Enum to represent the direction of the [InteractiveLayer] state change
/// animation.
///
/// For example selecting a tool happens by a state change from
/// [InteractiveNormalState] to [InteractiveSelectedToolState] with a forward
/// this will help the [InteractiveLayer] to animate the transition forward so
/// we can see the tool being selected. since for deselecting we should see the
/// same animation but in reverse we can use the backward direction.
enum StateChangeAnimationDirection {
  /// The forward direction.
  forward,

  /// The backward direction.
  backward,
}
