import 'package:json_annotation/json_annotation.dart';

/// Differnet types of drawing parts.
enum DrawingParts {
  /// Used to show the marker.
  @JsonValue('marker')
  marker,

  /// Used to show the line.
  @JsonValue('line')
  line,
}
