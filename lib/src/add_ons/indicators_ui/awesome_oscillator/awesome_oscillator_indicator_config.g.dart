// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'awesome_oscillator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AwesomeOscillatorIndicatorConfig _$AwesomeOscillatorIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    AwesomeOscillatorIndicatorConfig(
      barStyle: json['barStyle'] == null
          ? const BarStyle()
          : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$AwesomeOscillatorIndicatorConfigToJson(
        AwesomeOscillatorIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pipSize': instance.pipSize,
      'barStyle': instance.barStyle,
    };
