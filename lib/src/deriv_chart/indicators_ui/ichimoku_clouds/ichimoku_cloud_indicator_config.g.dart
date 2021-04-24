// GENERATED CODE - DO NOT MODIFY BY HAND

// @dart=2.9

part of 'ichimoku_cloud_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IchimokuCloudIndicatorConfig _$IchimokuCloudIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return IchimokuCloudIndicatorConfig(
    baseLinePeriod: json['baseLinePeriod'] as int,
    conversionLinePeriod: json['conversionLinePeriod'] as int,
    laggingSpanOffset: json['laggingSpanOffset'] as int,
    spanBPeriod: json['spanBPeriod'] as int,
  );
}

Map<String, dynamic> _$IchimokuCloudIndicatorConfigToJson(
        IchimokuCloudIndicatorConfig instance) =>
    <String, dynamic>{
      'conversionLinePeriod': instance.conversionLinePeriod,
      'baseLinePeriod': instance.baseLinePeriod,
      'spanBPeriod': instance.spanBPeriod,
      'laggingSpanOffset': instance.laggingSpanOffset,
    };
