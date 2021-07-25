// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adx_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ADXIndicatorConfig _$ADXIndicatorConfigFromJson(Map<String, dynamic> json) {
  return ADXIndicatorConfig(
    period: json['period'] as int,
    smoothingPeriod: json['smoothingPeriod'] as int,
    showSeries: json['showSeries'] as bool,
    showChannelFill: json['showChannelFill'] as bool,
    showHistogram: json['showHistogram'] as bool,
  );
}

Map<String, dynamic> _$ADXIndicatorConfigToJson(ADXIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'showChannelFill': instance.showChannelFill,
      'showHistogram': instance.showHistogram,
      'showSeries': instance.showSeries,
    };
