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
    );

Map<String, dynamic> _$IchimokuCloudIndicatorConfigToJson(
        IchimokuCloudIndicatorConfig instance) =>
    <String, dynamic>{
      'conversionLinePeriod': instance.conversionLinePeriod,
      'baseLinePeriod': instance.baseLinePeriod,
      'spanBPeriod': instance.spanBPeriod,
      'laggingSpanOffset': instance.laggingSpanOffset,
    };
