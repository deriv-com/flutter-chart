import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_item_mobile.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_label_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_drawing_tool_config_mobile.g.dart';

/// Line drawing tool config
@JsonSerializable()
class LineDrawingToolConfigMobile extends DrawingToolConfig {
  /// Initializes
  const LineDrawingToolConfigMobile({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.lineStyle = const LineStyle(
      thickness: 0.9,
      color: BrandColors.coral,
    ),
    this.overlayStyle,
    this.pattern = DrawingPatterns.solid,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory LineDrawingToolConfigMobile.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingToolConfigMobileFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_line_mobile';

  @override
  Map<String, dynamic> toJson() => _$LineDrawingToolConfigMobileToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool overlay style
  @JsonKey(
    fromJson: _overlayStyleFromJson,
    toJson: _overlayStyleToJson,
  )
  final OverlayStyle? overlayStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-binary): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      LineDrawingToolItemMobile(
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  LineDrawingToolConfigMobile copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    OverlayStyle? overlayStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      LineDrawingToolConfigMobile(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        overlayStyle: overlayStyle ?? this.overlayStyle,
        pattern: pattern ?? this.pattern,
        edgePoints: edgePoints ?? this.edgePoints,
        number: number ?? this.number,
      );

  @override
  LineDrawingToolLabelPainter? getLabelPainter({
    required Point startPoint,
    required Point endPoint,
  }) {
    if (kIsWeb) {
      return null;
    } else {
      return MobileLineDrawingToolLabelPainter(
        const LineDrawingToolConfigMobile(),
        startPoint: startPoint,
        endPoint: endPoint,
      );
    }
  }

  static OverlayStyle? _overlayStyleFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return OverlayStyle(
      color: Color(json['color'] as int),
    );
  }

  static Map<String, dynamic>? _overlayStyleToJson(OverlayStyle? instance) {
    if (instance == null) {
      return null;
    }
    return {
      'color': instance.color.value,
    };
  }
}
