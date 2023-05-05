// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcb_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FractalChaosBandIndicatorConfig _$FractalChaosBandIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    FractalChaosBandIndicatorConfig(
      channelFill: json['channelFill'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$FractalChaosBandIndicatorConfigToJson(
        FractalChaosBandIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'channelFill': instance.channelFill,
    };
