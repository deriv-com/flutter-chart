import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/core/crosshair_variant.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A context class that manages crosshair behavior strategies.
///
/// This class implements the Strategy Pattern to select between different
/// crosshair behavior implementations based on the specified variant (small screen
/// or large screen). It encapsulates the logic for selecting the appropriate behavior
/// strategy, making it easier to switch between different crosshair styles.
///
/// Type Parameter:
/// - [T]: The specific type of Tick data that the crosshair behavior will work with.
///   This is typically a concrete implementation like Tick or Candle.
class CrosshairStrategyContext<T extends Tick> {
  /// Creates a new CrosshairStrategyContext.
  ///
  /// Parameters:
  /// - [smallScreenBehaviourBuilder]: A function that creates a CrosshairBehaviour
  ///   implementation optimized for small screens.
  /// - [largeScreenBehaviourBuilder]: A function that creates a CrosshairBehaviour
  ///   implementation optimized for large screens.
  CrosshairStrategyContext({
    required CrosshairBehaviour<T> Function() smallScreenBehaviourBuilder,
    required CrosshairBehaviour<T> Function() largeScreenBehaviourBuilder,
  })  : _smallScreenBehaviourBuilder = smallScreenBehaviourBuilder,
        _largeScreenBehaviourBuilder = largeScreenBehaviourBuilder;

  /// Builder function for the small screen behavior strategy.
  final CrosshairBehaviour<T> Function() _smallScreenBehaviourBuilder;

  /// Builder function for the large screen behavior strategy.
  final CrosshairBehaviour<T> Function() _largeScreenBehaviourBuilder;

  /// Cached instance of small screen behavior (lazily initialized).
  CrosshairBehaviour<T>? _smallScreenBehaviourInstance;

  /// Cached instance of large screen behavior (lazily initialized).
  CrosshairBehaviour<T>? _largeScreenBehaviourInstance;

  /// Gets the appropriate CrosshairBehaviour based on the specified variant.
  ///
  /// This method lazily initializes and returns the appropriate behavior strategy
  /// based on the provided crosshair variant. The behavior instances are cached
  /// after first creation for better performance.
  ///
  /// Parameters:
  /// - [variant]: The variant of crosshair to use (smallScreen or largeScreen)
  ///
  /// Returns:
  /// A CrosshairBehaviour instance appropriate for the specified variant.
  ///
  /// Throws:
  /// ArgumentError if an unknown crosshair variant is provided.
  CrosshairBehaviour<T> getBehaviour(CrosshairVariant variant) {
    switch (variant) {
      case CrosshairVariant.smallScreen:
        _smallScreenBehaviourInstance ??= _smallScreenBehaviourBuilder();
        return _smallScreenBehaviourInstance!;
      case CrosshairVariant.largeScreen:
        _largeScreenBehaviourInstance ??= _largeScreenBehaviourBuilder();
        return _largeScreenBehaviourInstance!;
      default:
        throw ArgumentError('Unknown crosshair variant: $variant');
    }
  }
}
