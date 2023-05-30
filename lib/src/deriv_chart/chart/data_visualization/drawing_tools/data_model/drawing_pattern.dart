/// Differnet types of drawing patterns.
enum DrawingPatterns {
  /// Used for solid line.
  solid,

  /// Used for dotted line.
  dotted,

  /// Used for dashed line.
  dashed,
}

/// Base class for drawing pattern json deserialization.
abstract class DrawingPattern {
  /// Enum with their corresponding JSON representation
  static const Map<DrawingPatterns, String> patternEnumMap =
      <DrawingPatterns, String>{
    DrawingPatterns.solid: 'solid',
    DrawingPatterns.dotted: 'dotted',
    DrawingPatterns.dashed: 'dashed',
  };

  /// Converts a JSON value to the corresponding enum value.
  static K enumDecode<K, V>(
    Map<K, V> enumValues,
    Object? source, {
    K? unknownValue,
  }) {
    if (source == null) {
      throw ArgumentError(
        'A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}',
      );
    }

    return enumValues.entries.singleWhere(
      (MapEntry<K, V> e) => e.value == source,
      orElse: () {
        if (unknownValue == null) {
          throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          );
        }
        return MapEntry(unknownValue, enumValues.values.first);
      },
    ).key;
  }
}
