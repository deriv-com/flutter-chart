// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ichimoku_cloud_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IchimokuCloudIndicatorConfig _$IchimokuCloudIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return IchimokuCloudIndicatorConfig(
    id: json['id'] as String?,
    baseLinePeriod: json['baseLinePeriod'] as int,
    conversionLinePeriod: json['conversionLinePeriod'] as int,
    laggingSpanOffset: json['laggingSpanOffset'] as int,
    spanBPeriod: json['spanBPeriod'] as int,
  );
}

Map<String, dynamic> _$IchimokuCloudIndicatorConfigToJson(
        IchimokuCloudIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversionLinePeriod': instance.conversionLinePeriod,
      'baseLinePeriod': instance.baseLinePeriod,
      'spanBPeriod': instance.spanBPeriod,
      'laggingSpanOffset': instance.laggingSpanOffset,
    };
