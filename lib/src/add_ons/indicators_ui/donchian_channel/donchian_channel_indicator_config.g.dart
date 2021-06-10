// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donchian_channel_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonchianChannelIndicatorConfig _$DonchianChannelIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return DonchianChannelIndicatorConfig(
    highPeriod: json['highPeriod'] as int,
    lowPeriod: json['lowPeriod'] as int,
    showChannelFill: json['showChannelFill'] as bool,
    upperLineStyle: json['upperLineStyle'] == null
        ? null
        : LineStyle.fromJson(json['upperLineStyle'] as Map<String, dynamic>),
    middleLineStyle: json['middleLineStyle'] == null
        ? null
        : LineStyle.fromJson(json['middleLineStyle'] as Map<String, dynamic>),
    lowerLineStyle: json['lowerLineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lowerLineStyle'] as Map<String, dynamic>),
    fillColor: const ColorConverter().fromJson(json['fillColor'] as int),
  );
}

Map<String, dynamic> _$DonchianChannelIndicatorConfigToJson(
        DonchianChannelIndicatorConfig instance) =>
    <String, dynamic>{
      'highPeriod': instance.highPeriod,
      'lowPeriod': instance.lowPeriod,
      'showChannelFill': instance.showChannelFill,
      'upperLineStyle': instance.upperLineStyle,
      'middleLineStyle': instance.middleLineStyle,
      'lowerLineStyle': instance.lowerLineStyle,
      'fillColor': const ColorConverter().toJson(instance.fillColor),
    };
