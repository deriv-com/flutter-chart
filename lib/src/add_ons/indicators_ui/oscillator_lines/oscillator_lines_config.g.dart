// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oscillator_lines_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OscillatorLinesConfig _$OscillatorLinesConfigFromJson(
    Map<String, dynamic> json) {
  return OscillatorLinesConfig(
    overBoughtPrice: (json['overBoughtPrice'] as num).toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num).toDouble(),
    overboughtStyle:
        LineStyle.fromJson(json['overboughtStyle'] as Map<String, dynamic>),
    oversoldStyle:
        LineStyle.fromJson(json['oversoldStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$OscillatorLinesConfigToJson(
        OscillatorLinesConfig instance) =>
    <String, dynamic>{
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'overboughtStyle': instance.overboughtStyle,
      'oversoldStyle': instance.oversoldStyle,
    };
