// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adx_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ADXIndicatorConfig _$ADXIndicatorConfigFromJson(Map<String, dynamic> json) =>
    ADXIndicatorConfig(
      period: json['period'] as int? ?? 14,
      smoothingPeriod: json['smoothingPeriod'] as int? ?? 14,
      showSeries: json['showSeries'] as bool? ?? true,
      showChannelFill: json['showChannelFill'] as bool? ?? false,
      showHistogram: json['showHistogram'] as bool? ?? false,
    );

Map<String, dynamic> _$ADXIndicatorConfigToJson(ADXIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'showChannelFill': instance.showChannelFill,
      'showHistogram': instance.showHistogram,
      'showSeries': instance.showSeries,
    };
