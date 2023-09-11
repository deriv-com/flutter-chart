// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scatter_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScatterStyle _$ScatterStyleFromJson(Map<String, dynamic> json) => ScatterStyle(
      color: json['color'] == null
          ? const Color(0xFF85ACB0)
          : const ColorConverter().fromJson(json['color'] as int),
      radius: (json['radius'] as num?)?.toDouble() ?? 1.5,
    );

Map<String, dynamic> _$ScatterStyleToJson(ScatterStyle instance) =>
    <String, dynamic>{
      'color': const ColorConverter().toJson(instance.color),
      'radius': instance.radius,
    };
