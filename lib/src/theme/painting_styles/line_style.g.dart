// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStyle _$LineStyleFromJson(Map<String, dynamic> json) {
  return LineStyle(
    color: const ColorConverter().fromJson(json['color'] as int),
    thickness: (json['thickness'] as num)?.toDouble(),
    hasArea: json['hasArea'] as bool,
    lastTickStyle: json['lastTickStyle'] == null
        ? null
        : HorizontalBarrierStyle.fromJson(
            json['lastTickStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LineStyleToJson(LineStyle instance) => <String, dynamic>{
      'lastTickStyle': instance.lastTickStyle,
      'color': const ColorConverter().toJson(instance.color),
      'thickness': instance.thickness,
      'hasArea': instance.hasArea,
    };
