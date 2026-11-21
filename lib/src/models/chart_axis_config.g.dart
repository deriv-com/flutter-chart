// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_axis_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartAxisConfig _$ChartAxisConfigFromJson(Map<String, dynamic> json) =>
    ChartAxisConfig(
      initialTopBoundQuote:
          (json['initialTopBoundQuote'] as num?)?.toDouble() ??
              defaultTopBoundQuote,
      initialBottomBoundQuote:
          (json['initialBottomBoundQuote'] as num?)?.toDouble() ??
              defaultBottomBoundQuote,
      maxCurrentTickOffset:
          (json['maxCurrentTickOffset'] as num?)?.toDouble() ??
              defaultMaxCurrentTickOffset,
      defaultIntervalWidth:
          (json['defaultIntervalWidth'] as num?)?.toDouble() ?? 20,
      showQuoteGrid: json['showQuoteGrid'] as bool? ?? true,
      showEpochGrid: json['showEpochGrid'] as bool? ?? true,
      showFrame: json['showFrame'] as bool? ?? false,
      smoothScrolling: json['smoothScrolling'] as bool? ?? true,
    );

Map<String, dynamic> _$ChartAxisConfigToJson(ChartAxisConfig instance) =>
    <String, dynamic>{
      'initialTopBoundQuote': instance.initialTopBoundQuote,
      'initialBottomBoundQuote': instance.initialBottomBoundQuote,
      'maxCurrentTickOffset': instance.maxCurrentTickOffset,
      'showQuoteGrid': instance.showQuoteGrid,
      'showEpochGrid': instance.showEpochGrid,
      'showFrame': instance.showFrame,
      'defaultIntervalWidth': instance.defaultIntervalWidth,
      'smoothScrolling': instance.smoothScrolling,
    };
