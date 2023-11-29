// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oscillator_lines_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OscillatorLinesConfig _$OscillatorLinesConfigFromJson(
        Map<String, dynamic> json) =>
    OscillatorLinesConfig(
      overboughtValue: (json['overboughtValue'] as num).toDouble(),
      oversoldValue: (json['oversoldValue'] as num).toDouble(),
      overboughtStyle: json['overboughtStyle'] == null
          ? const LineStyle(thickness: 0.5)
          : LineStyle.fromJson(json['overboughtStyle'] as Map<String, dynamic>),
      oversoldStyle: json['oversoldStyle'] == null
          ? const LineStyle(thickness: 0.5)
          : LineStyle.fromJson(json['oversoldStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OscillatorLinesConfigToJson(
        OscillatorLinesConfig instance) =>
    <String, dynamic>{
      'overboughtValue': instance.overboughtValue,
      'oversoldValue': instance.oversoldValue,
      'overboughtStyle': instance.overboughtStyle,
      'oversoldStyle': instance.oversoldStyle,
    };
