// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donchian_channel_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonchianChannelIndicatorConfig _$DonchianChannelIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    DonchianChannelIndicatorConfig(
      highPeriod: json['highPeriod'] as int? ?? 10,
      lowPeriod: json['lowPeriod'] as int? ?? 10,
      showChannelFill: json['showChannelFill'] as bool? ?? true,
      upperLineStyle: json['upperLineStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(json['upperLineStyle'] as Map<String, dynamic>),
      middleLineStyle: json['middleLineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['middleLineStyle'] as Map<String, dynamic>),
      lowerLineStyle: json['lowerLineStyle'] == null
          ? const LineStyle(color: Colors.green)
          : LineStyle.fromJson(json['lowerLineStyle'] as Map<String, dynamic>),
      fillColor: json['fillColor'] == null
          ? Colors.white12
          : const ColorConverter().fromJson(json['fillColor'] as int),
    );

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
