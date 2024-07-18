// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ichimoku_cloud_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IchimokuCloudIndicatorConfig _$IchimokuCloudIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    IchimokuCloudIndicatorConfig(
      baseLinePeriod: json['baseLinePeriod'] as int? ?? 26,
      conversionLinePeriod: json['conversionLinePeriod'] as int? ?? 9,
      laggingSpanOffset: json['laggingSpanOffset'] as int? ?? -26,
      spanBPeriod: json['spanBPeriod'] as int? ?? 52,
      conversionLineStyle: json['conversionLineStyle'] == null
          ? const LineStyle(color: Colors.indigo)
          : LineStyle.fromJson(
              json['conversionLineStyle'] as Map<String, dynamic>),
      baseLineStyle: json['baseLineStyle'] == null
          ? const LineStyle(color: Colors.redAccent)
          : LineStyle.fromJson(json['baseLineStyle'] as Map<String, dynamic>),
      spanALineStyle: json['spanALineStyle'] == null
          ? const LineStyle(color: Colors.green)
          : LineStyle.fromJson(json['spanALineStyle'] as Map<String, dynamic>),
      spanBLineStyle: json['spanBLineStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(json['spanBLineStyle'] as Map<String, dynamic>),
      laggingLineStyle: json['laggingLineStyle'] == null
          ? const LineStyle(color: Colors.lime)
          : LineStyle.fromJson(
              json['laggingLineStyle'] as Map<String, dynamic>),
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$IchimokuCloudIndicatorConfigToJson(
        IchimokuCloudIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'conversionLinePeriod': instance.conversionLinePeriod,
      'baseLinePeriod': instance.baseLinePeriod,
      'spanBPeriod': instance.spanBPeriod,
      'laggingSpanOffset': instance.laggingSpanOffset,
      'conversionLineStyle': instance.conversionLineStyle,
      'baseLineStyle': instance.baseLineStyle,
      'spanALineStyle': instance.spanALineStyle,
      'spanBLineStyle': instance.spanBLineStyle,
      'laggingLineStyle': instance.laggingLineStyle,
    };
