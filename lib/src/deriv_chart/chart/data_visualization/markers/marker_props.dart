/// Properties for markers that can be used across all platforms
class MarkerProps {
  /// Creates a new [MarkerProps] instance
  const MarkerProps({
    this.hasPersistentBorders = false,
  });

  /// Creates a [MarkerProps] instance from a Map
  factory MarkerProps.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MarkerProps();
    }

    return MarkerProps(
      hasPersistentBorders: map['hasPersistentBorders'] as bool? ?? false,
    );
  }

  /// Whether the marker has persistent borders
  final bool hasPersistentBorders;

  /// Converts this [MarkerProps] instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'hasPersistentBorders': hasPersistentBorders,
    };
  }
}
