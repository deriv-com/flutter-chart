// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcb_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FractalChaosBandIndicatorConfig _$FractalChaosBandIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    FractalChaosBandIndicatorConfig(
      highLineStyle: json['highLineStyle'] == null
          ? const LineStyle(color: Colors.blue)
          : LineStyle.fromJson(json['highLineStyle'] as Map<String, dynamic>),
      lowLineStyle: json['lowLineStyle'] == null
          ? const LineStyle(color: Colors.blue)
          : LineStyle.fromJson(json['lowLineStyle'] as Map<String, dynamic>),
      fillColor: json['fillColor'] == null
          ? Colors.white12
          : const ColorConverter().fromJson(json['fillColor'] as int),
      showChannelFill: json['showChannelFill'] as bool? ?? false,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
      pipSize: json['pipSize'] as int? ?? 4,
    );

Map<String, dynamic> _$FractalChaosBandIndicatorConfigToJson(
        FractalChaosBandIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'highLineStyle': instance.highLineStyle,
      'lowLineStyle': instance.lowLineStyle,
      'fillColor': const ColorConverter().toJson(instance.fillColor),
      'showChannelFill': instance.showChannelFill,
    };
