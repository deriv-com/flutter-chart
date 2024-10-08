import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'channel_drawing_tool_item.dart';

part 'channel_drawing_tool_config.g.dart';

/// Channel drawing tool config
@JsonSerializable()
class ChannelDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const ChannelDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory ChannelDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$ChannelDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_channel';

  @override
  Map<String, dynamic> toJson() => _$ChannelDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-binary): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      ChannelDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  ChannelDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      ChannelDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        fillStyle: fillStyle ?? this.fillStyle,
        pattern: pattern ?? this.pattern,
        edgePoints: edgePoints ?? this.edgePoints,
        number: number ?? this.number,
      );
}
