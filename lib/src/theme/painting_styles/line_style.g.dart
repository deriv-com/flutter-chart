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
      hasArea: json['hasArea'] as bool? ?? false,
    );

Map<String, dynamic> _$LineStyleToJson(LineStyle instance) => <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'thickness': instance.thickness,
      'hasArea': instance.hasArea,
    };
