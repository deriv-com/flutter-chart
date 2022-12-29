// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oscillator_lines_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OscillatorLinesConfig _$OscillatorLinesConfigFromJson(
    Map<String, dynamic> json) {
  return OscillatorLinesConfig(
    overboughtValue: (json['overboughtValue'] as num).toDouble(),
    oversoldValue: (json['oversoldValue'] as num).toDouble(),
    overboughtStyle:
        LineStyle.fromJson(json['overboughtStyle'] as Map<String, dynamic>),
    oversoldStyle:
        LineStyle.fromJson(json['oversoldStyle'] as Map<String, dynamic>),
    id: json['id'] as String?,
  );
}

Map<String, dynamic> _$OscillatorLinesConfigToJson(
        OscillatorLinesConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'overboughtValue': instance.overboughtValue,
      'oversoldValue': instance.oversoldValue,
      'overboughtStyle': instance.overboughtStyle,
      'oversoldStyle': instance.oversoldStyle,
    };
