import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_tool_label_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:flutter/material.dart';

/// Drawing tools config
@immutable
abstract class DrawingToolConfig extends AddOnConfig {
  /// Initializes
  const DrawingToolConfig({
    required this.configId,
    required this.drawingData,
    // TODO(Bahar-Deriv): Move edgePoints to drawingData.
    required this.edgePoints,
    bool isOverlay = true,
    super.number,
  }) : super(isOverlay: isOverlay);

  /// Creates a concrete drawing tool config from JSON.
  factory DrawingToolConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(nameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing drawing tool name.');
    }

    switch (json[nameKey]) {
      case ChannelDrawingToolConfig.name:
        return ChannelDrawingToolConfig.fromJson(json);
      case ContinuousDrawingToolConfig.name:
        return ContinuousDrawingToolConfig.fromJson(json);
      case FibfanDrawingToolConfig.name:
        return FibfanDrawingToolConfig.fromJson(json);
      case HorizontalDrawingToolConfig.name:
        return HorizontalDrawingToolConfig.fromJson(json);
      case LineDrawingToolConfig.name:
        return LineDrawingToolConfig.fromJson(json);
      case LineDrawingToolConfigMobile.name:
        return LineDrawingToolConfigMobile.fromJson(json);
      case RayDrawingToolConfig.name:
        return RayDrawingToolConfig.fromJson(json);
      case RectangleDrawingToolConfig.name:
        return RectangleDrawingToolConfig.fromJson(json);
      case TrendDrawingToolConfig.name:
        return TrendDrawingToolConfig.fromJson(json);
      case VerticalDrawingToolConfig.name:
        return VerticalDrawingToolConfig.fromJson(json);

      // Add new drawing tools here.
      default:
        throw ArgumentError.value(
            json, 'json', 'Unidentified drawing tool name.');
    }
  }

  /// Drawing tool data.
  final DrawingData? drawingData;

  /// Drawing tool edge points.
  final List<EdgePoint> edgePoints;

  /// Drawing tool config id.
  final String? configId;

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'name';

  /// Key of drawing tool config id property in JSON.
  static String configIdKey = 'configId';

  /// Returns back the [InteractableDrawing] instance of this drawing tool.
  InteractableDrawing getInteractableDrawing() {
    throw UnimplementedError('getInteractableDrawing() is not implemented.');
  }

  /// Creates a copy of this object.
  DrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  });

  /// Creates drawing tool.
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  );

  /// Create label painter for the drawing tool.
  DrawingToolLabelPainter? getLabelPainter({
    required Point startPoint,
    required Point endPoint,
  }) =>
      null;
}
