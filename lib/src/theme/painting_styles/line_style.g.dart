// GENERATED CODE - DO NOT MODIFY BY HAND

// @dart=2.9

part of 'line_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStyle _$LineStyleFromJson(Map<String, dynamic> json) {
  return LineStyle(
    color: const ColorConverter().fromJson(json['color'] as int),
    thickness: (json['thickness'] as num)?.toDouble(),
    hasArea: json['hasArea'] as bool,
  );
}

Map<String, dynamic> _$LineStyleToJson(LineStyle instance) => <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'thickness': instance.thickness,
      'hasArea': instance.hasArea,
    };
