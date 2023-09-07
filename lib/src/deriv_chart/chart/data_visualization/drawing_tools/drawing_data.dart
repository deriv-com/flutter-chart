import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drawing_data.g.dart';

/// A class that hold drawing data.
@JsonSerializable()
class DrawingData {
  /// Initializes
  DrawingData({
    required this.id,
    required this.drawingParts,
    this.isDrawingFinished = false,
    this.isSelected = true,
    this.series,
  });

  /// Initializes from JSON.
  factory DrawingData.fromJson(Map<String, dynamic> json) =>
      _$DrawingDataFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$DrawingDataToJson(this);

  /// Unique id of the current drawing.
  final String id;

  /// Series of ticks
  List<Tick>? series;

  /// Drawing list.
  final List<Drawing> drawingParts;

  /// If drawing is finished.
  bool isDrawingFinished;

  /// If the drawing is selected by the user.
  bool isSelected;
}
