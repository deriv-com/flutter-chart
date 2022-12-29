// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'awesome_oscillator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AwesomeOscillatorIndicatorConfig _$AwesomeOscillatorIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return AwesomeOscillatorIndicatorConfig(
    id: json['id'] as String?,
    barStyle: BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AwesomeOscillatorIndicatorConfigToJson(
        AwesomeOscillatorIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'barStyle': instance.barStyle,
    };
