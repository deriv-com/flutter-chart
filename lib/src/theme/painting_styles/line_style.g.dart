// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStyle _$LineStyleFromJson(Map<String, dynamic> json) => LineStyle(
      color: json['color'] == null
          ? const Color(0xFF85ACB0)
          : const ColorConverter().fromJson(json['color'] as int),
      thickness: (json['thickness'] as num?)?.toDouble() ?? 1,
      pattern: $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
          DrawingPatterns.solid,
      hasArea: json['hasArea'] as bool? ?? false,
    );

Map<String, dynamic> _$LineStyleToJson(LineStyle instance) => <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'thickness': instance.thickness,
      'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
      'hasArea': instance.hasArea,
    };

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
